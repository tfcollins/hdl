###############################################################################
## Copyright (C) 2022-2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# environment related stuff
set ad_hdl_dir [file normalize [file join [file dirname [info script]] "../"]]

if [info exists ::env(ADI_HDL_DIR)] {
  set ad_hdl_dir [file normalize $::env(ADI_HDL_DIR)]
} else {
  set env(ADI_HDL_DIR) $ad_hdl_dir
}

if [info exists ::env(ADI_GHDL_DIR)] {
  set ad_ghdl_dir [file normalize $::env(ADI_GHDL_DIR)]
}

# Define the supported tool version
set required_vivado_version "2025.1"
if {[info exists ::env(REQUIRED_VIVADO_VERSION)]} {
  set required_vivado_version $::env(REQUIRED_VIVADO_VERSION)
} elseif {[info exists REQUIRED_VIVADO_VERSION]} {
  set required_vivado_version $REQUIRED_VIVADO_VERSION
}

# Define the ADI_IGNORE_VERSION_CHECK environment variable to skip version check
if {[info exists ::env(ADI_IGNORE_VERSION_CHECK)]} {
  set IGNORE_VERSION_CHECK 1
} elseif {![info exists IGNORE_VERSION_CHECK]} {
  set IGNORE_VERSION_CHECK 0
}

# Check $QUARTUS_PRO_ISUSED environment variables
# If it's not defined auto-detect it based on  the project name
set quartus_pro_isused 1
if {[info exists ::env(QUARTUS_PRO_ISUSED)]} {
  set quartus_pro_isused $::env(QUARTUS_PRO_ISUSED)
} elseif {[info exists QUARTUS_PRO_ISUSED]} {
  set quartus_pro_isused $QUARTUS_PRO_ISUSED
} else {
  set quartus_std_carriers {de10nano c5soc}

  foreach carrier $quartus_std_carriers {
    if {[string match "*$carrier*" [pwd]]} {
      set quartus_pro_isused 0
      break
    }
  }
}

# Define the supported tool version
# If the variable is not defined, set it to standard if the carrier requires it
set required_quartus_version "25.3.0"
set required_quartus_std_version "24.1std.0"
if {[info exists ::env(REQUIRED_QUARTUS_VERSION)]} {
  set required_quartus_version $::env(REQUIRED_QUARTUS_VERSION)
} elseif {[info exists REQUIRED_QUARTUS_VERSION]} {
  set required_quartus_version $REQUIRED_QUARTUS_VERSION
} elseif {$quartus_pro_isused == 0} {
  set required_quartus_version $required_quartus_std_version
}

# Define the supported tool version
set required_lattice_version "2025.2"
if {[info exists ::env(REQUIRED_LATTICE_VERSION)]} {
  set required_lattice_version $::env(REQUIRED_LATTICE_VERSION)
} elseif {[info exists REQUIRED_LATTICE_VERSION]} {
  set required_lattice_version $REQUIRED_LATTICE_VERSION
}

# This helper pocedure retrieves the value of varible from environment if exists,
# other case returns the provided default value
#  name - name of the environment variable
#  default_value - returned vale in case environment variable does not exists
proc get_env_param {name default_value} {
  if [info exists ::env($name)] {
    puts "Getting from environment the parameter: $name=$::env($name) "
    return $::env($name)
  } else {
    return $default_value
  }
}

# Returns a usable CPU core count (cross platform). Falls back to 1 when it
# cannot be determined (e.g. nproc missing and NUMBER_OF_PROCESSORS unset).
proc adi_cpu_count {} {
  set cores 1
  if {![catch {exec nproc} out] && [string is integer -strict [string trim $out]]} {
    set cores [string trim $out]
  } elseif {[info exists ::env(NUMBER_OF_PROCESSORS)] && \
            [string is integer -strict $::env(NUMBER_OF_PROCESSORS)]} {
    set cores $::env(NUMBER_OF_PROCESSORS)
  }
  if {$cores < 1} {
    set cores 1
  }
  return $cores
}

# Resolves a parallel-jobs count from the environment. Precedence:
#   $override env var (when set) > ADI_MAX_JOBS env var > $default
# A value of 0 or "auto" means "use all available CPU cores". An invalid value
# falls back to 1. This is the single knob used across the build flows
# (IP packaging and out-of-context synthesis).
proc adi_resolve_jobs {default {override ""}} {
  if {$override ne "" && [info exists ::env($override)]} {
    set n $::env($override)
  } elseif {[info exists ::env(ADI_MAX_JOBS)]} {
    set n $::env(ADI_MAX_JOBS)
  } else {
    set n $default
  }
  if {$n eq "auto" || ([string is integer -strict $n] && $n == 0)} {
    set n [adi_cpu_count]
  }
  if {![string is integer -strict $n] || $n < 1} {
    puts "WARNING: invalid job count '$n', falling back to 1"
    set n 1
  }
  return $n
}
