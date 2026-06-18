###############################################################################
## Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

##############################################################################
## The folowing procedures are available:
##
## adi_make::lib <args> [jobs]
##               -"all"(project libraries)
##               -"library name to build (plus path to it relative to library folder)
##                  e.g.: adi_make_lib xilinx/util_adxcvr
##               - optional [jobs]: max number of IPs to package in parallel.
##                  Overrides the ADI_MAX_JOBS environment variable. Defaults to
##                  1 (serial, legacy behaviour). Use 0 to use all CPU cores.
## adi_make::boot_bin - expected that u-boot*.elf (plus bl31.elf for zynq_mp)
##                     files are in the project folder"
## For more info please see: https://wiki.analog.com/resources/fpga/docs/build
##
## Parallelism: IPs are packaged concurrently with a bounded pool of Vivado
## processes while honouring the inter-IP dependency graph (an IP's
## XILINX_*_DEPS are packaged before the IP itself; independent IPs run in
## parallel). Each IP is packaged in its own Vivado process with cwd set to the
## IP directory and its log written to <ip>_ip.log. Library IP packaging writes
## only to the IP's own directory and does not use the shared ipcache, so
## sibling IPs are safe to build at the same time.



namespace eval adi_make {
  ##############################################################################
  # to print debug step messages "set debug_msg=1" (set adi_make::debug_msg 1)
  variable debug_msg 0
  ##############################################################################

  variable library_dir
  variable PWD [pwd]
  variable root_hdl_folder
  variable indent_level ""

  # scheduler state (populated per adi_make::lib call)
  variable graph          ;# graph(<ip>)  -> list of dependency IP names
  variable state          ;# state(<ip>)  -> unbuilt | running | done | failed | skipped
  variable running        ;# running(<chan>) -> ip currently building on that channel
  variable max_jobs 1     ;# resolved parallelism for the current call
  variable build_failures ;# list of {ip reason}
  variable pump 0         ;# vwait trigger, bumped whenever a build finishes

  # get library absolute path
  set root_hdl_folder ""
  set glb_path $PWD
  if { [regexp projects $glb_path] } {
    regsub {/projects.*$} $glb_path "" root_hdl_folder
  } else {
    puts "ERROR: Not in hdl/* folder"
    return
  }

  set library_dir "$root_hdl_folder/library"

  #----------------------------------------------------------------------------
  # have debug messages
  proc puts_msg { message } {
    variable debug_msg
    variable indent_level
    if { $debug_msg == 1 } {
      puts $indent_level$message
    }
  }

  #----------------------------------------------------------------------------
  # returns the projects required set of libraries
  proc get_libraries {} {

    set build_list ""

    set search_pattern "LIB_DEPS.*="
    set fp1 [open ./Makefile r]
    set file_data [read $fp1]
    close $fp1

    set lines [split $file_data \n]
    foreach line $lines {
      if { [regexp $search_pattern $line] } {
        regsub -all $search_pattern $line "" library
        set library [string trim $library]
        puts_msg "\t- project dep: $library"
        append build_list "$library "
      }
    }
    return $build_list
  }

  #----------------------------------------------------------------------------
  # resolve the requested parallelism: explicit arg > ADI_MAX_JOBS env > 1.
  # A value of 0 (or "auto") means use all available CPU cores.
  proc resolve_max_jobs { jobs } {
    global env
    if { $jobs ne "" } {
      set n $jobs
    } elseif { [info exists env(ADI_MAX_JOBS)] } {
      set n $env(ADI_MAX_JOBS)
    } else {
      set n 1
    }
    if { $n eq "auto" || ([string is integer -strict $n] && $n == 0) } {
      set n [core_count]
    }
    if { ![string is integer -strict $n] || $n < 1 } {
      puts "WARNING: invalid job count '$n', falling back to 1"
      set n 1
    }
    return $n
  }

  #----------------------------------------------------------------------------
  # best-effort CPU core count (cross platform); used when jobs == 0/"auto"
  proc core_count {} {
    global env
    set cores 1
    if { ![catch { exec nproc } out] && [string is integer -strict [string trim $out]] } {
      set cores [string trim $out]
    } elseif { [info exists env(NUMBER_OF_PROCESSORS)] && \
               [string is integer -strict $env(NUMBER_OF_PROCESSORS)] } {
      set cores $env(NUMBER_OF_PROCESSORS)
    }
    if { $cores < 1 } { set cores 1 }
    return $cores
  }

  #----------------------------------------------------------------------------
  # parse an IP's Makefile for its XILINX_*_DEPS dependency IP names.
  # (matches XILINX_LIB_DEPS and XILINX_INTERFACE_DEPS, not the XILINX_DEPS
  #  file list - same behaviour as the legacy recursive builder)
  proc get_deps { ip } {
    variable library_dir

    set mkpath "$library_dir/$ip/Makefile"
    if { ![file exists $mkpath] } {
      error "Makefile not found for IP '$ip' (expected $mkpath)"
    }

    set fp1 [open $mkpath r]
    set file_data [read $fp1]
    close $fp1

    set search_pattern {XILINX_.*_DEPS.*=}
    set deps ""
    foreach line [split $file_data \n] {
      if { [regexp $search_pattern $line] } {
        regsub -all $search_pattern $line "" rest
        foreach tok [regexp -all -inline {\S+} $rest] {
          lappend deps $tok
        }
      }
    }
    return $deps
  }

  #----------------------------------------------------------------------------
  # build the full dependency graph (iteratively) starting from the seed nodes,
  # then verify it is acyclic.
  proc build_graph { nodes } {
    variable graph
    variable state

    array unset graph
    array unset state

    set worklist $nodes
    while { [llength $worklist] > 0 } {
      set node [lindex $worklist 0]
      set worklist [lrange $worklist 1 end]
      if { [info exists state($node)] } { continue }

      set deps [get_deps $node]
      set graph($node) $deps
      set state($node) unbuilt
      puts_msg "graph: $node -> $deps"

      foreach d $deps {
        if { ![info exists state($d)] } {
          lappend worklist $d
        }
      }
    }

    check_cycles
  }

  #----------------------------------------------------------------------------
  # DFS colouring; raises on a dependency cycle
  proc check_cycles {} {
    variable graph
    variable _color

    array unset _color
    foreach n [array names graph] { set _color($n) white }
    foreach n [array names graph] {
      if { $_color($n) eq "white" } { dfs_visit $n {} }
    }
    array unset _color
  }

  proc dfs_visit { node path } {
    variable graph
    variable _color

    set _color($node) gray
    foreach d $graph($node) {
      switch -- $_color($d) {
        gray  { error "dependency cycle detected: [join [concat $path $node $d] { -> }]" }
        white { dfs_visit $d [concat $path $node] }
      }
    }
    set _color($node) black
  }

  #----------------------------------------------------------------------------
  # an IP is ready when it is still unbuilt and all of its deps are done
  proc node_ready { ip } {
    variable graph
    variable state

    if { $state($ip) ne "unbuilt" } { return 0 }
    foreach d $graph($ip) {
      if { $state($d) ne "done" } { return 0 }
    }
    return 1
  }

  #----------------------------------------------------------------------------
  # mark (transitively) every unbuilt IP that depends on a failed/skipped IP
  # as skipped, so we never try to build on top of a broken dependency
  proc block_failed_dependents {} {
    variable graph
    variable state
    variable build_failures

    set changed 1
    while { $changed } {
      set changed 0
      foreach ip [array names state] {
        if { $state($ip) ne "unbuilt" } { continue }
        foreach d $graph($ip) {
          if { $state($d) eq "failed" || $state($d) eq "skipped" } {
            set state($ip) skipped
            lappend build_failures [list $ip "skipped (dependency $d failed)"]
            puts "- SKIPPED $ip (dependency $d failed)"
            set changed 1
            break
          }
        }
      }
    }
  }

  #----------------------------------------------------------------------------
  # launch the packaging of one ready IP in its own Vivado process
  proc spawn_build { ip } {
    variable library_dir
    variable state
    variable running
    variable build_failures

    set ip_dir "$library_dir/$ip"
    set lib_name "[file tail $ip]_ip"
    set src "$ip_dir/${lib_name}.tcl"

    # the child must start with cwd = the IP directory ('_ip.tcl' uses relative
    # 'source ../../scripts/adi_env.tcl' and relative file refs, and -log is
    # written relative to cwd). The child inherits cwd at the 'open' instant;
    # Tcl is single threaded so no other op interleaves before we cd back.
    set cmd [list vivado -mode batch -nojournal -log ${lib_name}.log -source $src]
    set save [pwd]
    cd $ip_dir
    set rc [catch { open "|$cmd" r } chan]
    cd $save

    if { $rc } {
      set state($ip) failed
      lappend build_failures [list $ip "could not launch vivado: $chan"]
      puts "- FAILED launching $ip: $chan"
      return
    }

    fconfigure $chan -blocking 0
    set state($ip) running
    set running($chan) $ip
    puts_msg "spawn: $ip (running=[array size running])"
    fileevent $chan readable [namespace code [list on_readable $chan]]
  }

  #----------------------------------------------------------------------------
  # drain a build's output; on EOF reap it and record done/failed
  proc on_readable { chan } {
    variable library_dir
    variable state
    variable running
    variable build_failures
    variable pump

    if { ![eof $chan] } {
      # discard output (vivado also writes it to <ip>_ip.log); the read keeps
      # the pipe buffer from filling and blocking the child
      catch { read $chan }
      return
    }

    fileevent $chan readable {}
    set ip $running($chan)
    unset running($chan)

    # switch back to blocking so close reaps the child and reports a non-zero
    # exit status (a non-blocking close may return before the child is reaped
    # and would silently drop the failure)
    fconfigure $chan -blocking 1
    set rc [catch { close $chan } cmsg copts]
    if { $rc } {
      set code "?"
      if { [dict exists $copts -errorcode] } {
        set ec [dict get $copts -errorcode]
        if { [lindex $ec 0] eq "CHILDSTATUS" } { set code [lindex $ec 2] }
      }
      set state($ip) failed
      lappend build_failures [list $ip "vivado exit $code"]
      puts "- FAILED building $ip (exit $code) - see $library_dir/$ip/[file tail $ip]_ip.log"
    } else {
      set state($ip) done
      puts "- Done building $ip"
    }

    incr pump
  }

  #----------------------------------------------------------------------------
  # all graph nodes are in a terminal state (nothing left to build)?
  proc all_terminal {} {
    variable state
    foreach ip [array names state] {
      if { $state($ip) eq "unbuilt" || $state($ip) eq "running" } { return 0 }
    }
    return 1
  }

  proc unbuilt_nodes {} {
    variable state
    set out ""
    foreach ip [array names state] {
      if { $state($ip) eq "unbuilt" } { lappend out $ip }
    }
    return $out
  }

  #----------------------------------------------------------------------------
  # worker-pool + DAG scheduler. Launches ready IPs up to max_jobs, waits for a
  # build to finish, then rescans (a finished dep can unblock its dependents).
  proc run_scheduler {} {
    variable state
    variable running
    variable max_jobs
    variable pump

    set pump 0
    array unset running

    while { 1 } {
      block_failed_dependents

      foreach ip [lsort [array names state]] {
        if { [array size running] >= $max_jobs } { break }
        if { [node_ready $ip] } { spawn_build $ip }
      }

      if { [array size running] == 0 } {
        if { [all_terminal] } { break }
        # nothing running and nothing ready, yet unbuilt nodes remain
        error "build scheduler stuck (unsatisfiable deps): [unbuilt_nodes]"
      }

      vwait [namespace current]::pump
    }
  }

  #----------------------------------------------------------------------------
  proc lib { libraries {jobs ""} } {

    variable library_dir
    variable PWD
    variable max_jobs
    variable graph
    variable state
    variable running
    variable build_failures

    set max_jobs [resolve_max_jobs $jobs]

    set build_list $libraries
    if { $libraries eq "all" } {
      set build_list "[get_libraries]"
    }

    puts "Building (max parallel jobs: $max_jobs):"
    set search_paths ""
    foreach b_lib $build_list {
      puts "- $b_lib"
      append search_paths "$library_dir/$b_lib "
    }
    puts "Please wait, this might take a few minutes"

    # discover buildable IP dirs under the requested paths (up to 4 subdir
    # levels), then reduce them to node names relative to library/
    if { [lindex $search_paths 0] eq "" } {
      set search_paths "."
    }
    set makefiles ""
    foreach base $search_paths {
      set dir "$base/"
      for {set x 1} {$x <= 4} {incr x} {
        catch { append makefiles " [glob "${dir}Makefile"]" }
        append dir "*/"
      }
    }

    if { $makefiles eq "" } {
      puts "ERROR: No IP Makefiles found starting from \"$search_paths\""
      return
    }

    # keep only dirs that have a sibling <tail>_ip.tcl (actually buildable)
    set top_nodes ""
    foreach fs $makefiles {
      set lib_dir [file dirname $fs]
      set lib_name "[file tail $lib_dir]_ip.tcl"
      if { [file exists $lib_dir/$lib_name] } {
        set node $lib_dir
        regsub .*library/ $node "" node
        lappend top_nodes $node
      }
    }

    if { $top_nodes eq "" } {
      puts "ERROR: No buildable IPs (with <ip>_ip.tcl) found"
      return
    }

    # reset scheduler state and run
    array unset graph
    array unset state
    array unset running
    set build_failures ""

    build_graph $top_nodes
    run_scheduler

    cd $PWD

    set failed [llength $build_failures]
    array unset graph
    array unset state
    array unset running

    if { $failed > 0 } {
      puts "\nBuild FAILED for $failed IP(s):"
      foreach f $build_failures {
        puts "  - [lindex $f 0]: [lindex $f 1]"
      }
      return -code error "adi_make::lib: $failed IP(s) failed to build"
    }

    puts "\nAll IPs built successfully."
  }

  #----------------------------------------------------------------------------
  # backward-compatible single-IP entry point (builds the IP and its deps via
  # the parallel scheduler, honouring ADI_MAX_JOBS)
  proc build_lib { library {jobs ""} } {
    lib $library $jobs
  }

  #----------------------------------------------------------------------------
  # boot_bin build procedure
  proc boot_bin {} {

    variable root_hdl_folder

    set arm_tr_sw_elf "bl31.elf"
    set boot_bin_folder "boot_bin"
    if {[catch {set xsa_file "[glob "./*.sdk/system_top.xsa"]"} fid]} {
      puts stderr "ERROR: $fid\n\rNOTE: you must have built hdl project\n\
      \rSee: https://wiki.analog.com/resources/fpga/docs/build\n"
      return
    }
    if {[catch {set uboot_elf "[glob "./u-boot*.elf"]" } fid]} {
      puts stderr "ERROR: $fid\n\rNOTE: you must have a the u-boot.elf in [pwd]\n\
      \rSee: https://wiki.analog.com/resources/fpga/docs/build\n"
      return
    }

    puts "root_hdl_folder $root_hdl_folder"
    puts "uboot_elf $uboot_elf"
    puts "xsa_file $xsa_file"

    # determine if Xilinx SDK tools are set in the enviroment
    package require platform
    set os_type [platform::generic]
    if { [regexp ^win $os_type] } {
      set w_cmd where
    } elseif { [regexp ^linux $os_type] } {
      set w_cmd which
    } else {
      puts "ERROR: Unknown OS: $os_type"
      exit 1
    }
    set xsct_loc [exec $w_cmd xsct]

    # search for Xilinx Command Line Tool (SDK)
    if { $xsct_loc == "" } {
      puts $env(PATH)
      puts "ERROR: SDK not installed or it is not defined in the enviroment path"
      exit 1
    }

    set xsct_script "exec xsct $root_hdl_folder/projects/scripts/adi_make_boot_bin.tcl"
    set build_args "$xsa_file $uboot_elf $boot_bin_folder $arm_tr_sw_elf"
    puts "Please wait, this may take a few minutes."
    eval $xsct_script $build_args
  }

} ;# ad_make namespace


#############################################################################
#############################################################################
