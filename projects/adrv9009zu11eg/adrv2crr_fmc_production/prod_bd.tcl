set prod_dir [file normalize [file dirname [info script]]]

add_files -fileset constrs_1 -norecurse $prod_dir/prod_constr.xdc

# PL DDR4 data lane mapping (see system_top.v PL_DDR*_MAP)
#   0 - both parts, 32-bit; 1 - lower part only, 16-bit; 2 - upper part only, 16-bit

foreach {mig param} {0 PL_DDR0_MAP 1 PL_DDR1_MAP} {
  if {[info exists ad_project_params($param)]} {
    set pl_ddr_map($mig) $ad_project_params($param)
  } else {
    set pl_ddr_map($mig) 0
  }
  if {[lsearch {0 1 2} $pl_ddr_map($mig)] < 0} {
    error "$param must be 0, 1 or 2, got $pl_ddr_map($mig)"
  }
  if {$pl_ddr_map($mig) == 0} {
    set pl_ddr_dq_width($mig) 32
    set pl_ddr_axi_width($mig) 256
    set pl_ddr_axi_addr_width($mig) 31
  } else {
    set pl_ddr_dq_width($mig) 16
    set pl_ddr_axi_width($mig) 128
    set pl_ddr_axi_addr_width($mig) 30
  }
}

# The data pins of the unused part have no MIG driver, give them an I/O standard

array set pl_ddr_idle_part {0,1 u31 0,2 u30 1,1 u42 1,2 u41}
foreach mig {0 1} {
  if {$pl_ddr_map($mig) != 0} {
    add_files -fileset constrs_1 -norecurse \
      $prod_dir/pl_ddr_idle_$pl_ddr_idle_part($mig,$pl_ddr_map($mig)).xdc
  }
}

# ports

create_bd_port -dir I -from 31 -to 0 fmc_gpio_00_i
create_bd_port -dir O -from 31 -to 0 fmc_gpio_00_o
create_bd_port -dir O -from 31 -to 0 fmc_gpio_00_t
create_bd_port -dir I -from 31 -to 0 fmc_gpio_01_i
create_bd_port -dir O -from 31 -to 0 fmc_gpio_01_o
create_bd_port -dir O -from 31 -to 0 fmc_gpio_01_t
create_bd_port -dir I -from 3 -to 0 fmc_gpio_10_i
create_bd_port -dir O -from 3 -to 0 fmc_gpio_10_o
create_bd_port -dir O -from 3 -to 0 fmc_gpio_10_t

create_bd_port -dir I clk_mon_0
create_bd_port -dir I clk_mon_1
create_bd_port -dir I clk_mon_2
create_bd_port -dir I clk_mon_3
create_bd_port -dir I clk_mon_4
create_bd_port -dir I clk_mon_5

create_bd_port -dir I ref_clk_0
create_bd_port -dir I ref_clk_1

create_bd_port -dir O -from 0 -to 0 tx_p_0
create_bd_port -dir O -from 0 -to 0 tx_n_0
create_bd_port -dir I -from 0 -to 0 rx_p_0
create_bd_port -dir I -from 0 -to 0 rx_n_0

create_bd_port -dir O -from 3 -to 0 tx_p_1
create_bd_port -dir O -from 3 -to 0 tx_n_1
create_bd_port -dir I -from 3 -to 0 rx_p_1
create_bd_port -dir I -from 3 -to 0 rx_n_1

create_bd_port -dir O -from 9 -to 0 tx_p_2
create_bd_port -dir O -from 9 -to 0 tx_n_2
create_bd_port -dir I -from 9 -to 0 rx_p_2
create_bd_port -dir I -from 9 -to 0 rx_n_2

create_bd_port -dir O -from 7 -to 0 tx_p_3
create_bd_port -dir O -from 7 -to 0 tx_n_3
create_bd_port -dir I -from 7 -to 0 rx_p_3
create_bd_port -dir I -from 7 -to 0 rx_n_3

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_rtl_0
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr4_ref_0

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_0
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_1
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_2
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_3
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_4
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_5
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_6
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vaux_7
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 vp_vn

#XADC

ad_ip_instance system_management_wiz xadc_0 [list \
  OT_ALARM {false} \
  USER_TEMP_ALARM {false} \
  VCCINT_ALARM {false} \
  VCCAUX_ALARM {false} \
  ENABLE_VCCPSINTLP_ALARM {false} \
  ENABLE_VCCPSAUX_ALARM {false} \
  ENABLE_VCCPSINTFP_ALARM {false} \
  CHANNEL_ENABLE_VP_VN {true} \
  CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} \
  CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} \
  CHANNEL_ENABLE_VAUXP2_VAUXN2 {true} \
  CHANNEL_ENABLE_VAUXP3_VAUXN3 {true} \
  CHANNEL_ENABLE_VAUXP4_VAUXN4 {true} \
  CHANNEL_ENABLE_VAUXP5_VAUXN5 {true} \
  CHANNEL_ENABLE_VAUXP6_VAUXN6 {true} \
  CHANNEL_ENABLE_VAUXP7_VAUXN7 {true} \
  AVERAGE_ENABLE_VAUXP0_VAUXN0 {true} \
  AVERAGE_ENABLE_VAUXP1_VAUXN1 {true} \
  AVERAGE_ENABLE_VAUXP2_VAUXN2 {true} \
  AVERAGE_ENABLE_VAUXP3_VAUXN3 {true} \
  AVERAGE_ENABLE_VAUXP4_VAUXN4 {true} \
  AVERAGE_ENABLE_VAUXP5_VAUXN5 {true} \
  AVERAGE_ENABLE_VAUXP6_VAUXN6 {true} \
  AVERAGE_ENABLE_VAUXP7_VAUXN7 {true} \
  ACQUISITION_TIME_VAUXP0_VAUXN0 {true} \
  ACQUISITION_TIME_VAUXP1_VAUXN1 {true} \
  ACQUISITION_TIME_VAUXP2_VAUXN2 {true} \
  ACQUISITION_TIME_VAUXP3_VAUXN3 {true} \
  ACQUISITION_TIME_VAUXP4_VAUXN4 {true} \
  ACQUISITION_TIME_VAUXP5_VAUXN5 {true} \
  ACQUISITION_TIME_VAUXP6_VAUXN6 {true} \
  ACQUISITION_TIME_VAUXP7_VAUXN7 {true} \
  ANALOG_BANK_SELECTION {88} \
  VAUXN0_LOC {A11} \
  VAUXP0_LOC {A12} \
  VAUXN1_LOC {A10} \
  VAUXP1_LOC {B10} \
  VAUXN2_LOC {B11} \
  VAUXP2_LOC {C11} \
  VAUXN3_LOC {C12} \
  VAUXP3_LOC {D12} \
  VAUXN4_LOC {D10} \
  VAUXP4_LOC {D11} \
  VAUXN5_LOC {E12} \
  VAUXP5_LOC {F12} \
  VAUXN6_LOC {E10} \
  VAUXP6_LOC {F10} \
  VAUXN7_LOC {F11} \
  VAUXP7_LOC {G11} \
  ENABLE_TEMP_BUS {true} \
]

ad_connect vaux_0 xadc_0/Vaux0
ad_connect vaux_1 xadc_0/Vaux1
ad_connect vaux_2 xadc_0/Vaux2
ad_connect vaux_3 xadc_0/Vaux3
ad_connect vaux_4 xadc_0/Vaux4
ad_connect vaux_5 xadc_0/Vaux5
ad_connect vaux_6 xadc_0/Vaux6
ad_connect vaux_7 xadc_0/Vaux7
ad_connect vp_vn xadc_0/Vp_Vn

ad_disconnect const_gnd_0/dout axi_fan_control_0/temp_in
#delete_bd_objs [get_bd_cells const_gnd_0]
ad_connect xadc_0/temp_out axi_fan_control_0/temp_in
ad_ip_parameter axi_fan_control_0  CONFIG.INTERNAL_SYSMONE 0

#DDR4

ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP0 1
set_property -dict [list CONFIG.FREQ_HZ {300000000}] [get_bd_intf_ports ddr4_ref_0]

ad_ip_instance ip:ddr4 ddr4_0

ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_DataWidth $pl_ddr_dq_width(0)
ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_AxiDataWidth $pl_ddr_axi_width(0)
ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_AxiAddressWidth $pl_ddr_axi_addr_width(0)
#ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_TimePeriod {1250}
ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_InputClockPeriod {3334}
ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-075E}
ad_ip_parameter ddr4_0 CONFIG.C0.BANK_GROUP_WIDTH {1}
ad_ip_parameter ddr4_0 CONFIG.C0.DDR4_CasLatency {18}

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ddr4_0_rstgen

# ddr4_1 and the TX DAC FIFO are created in ../common/adrv9009zu11eg_bd.tcl as
# a 32-bit, 2 GB interface; narrow them when a single part is selected

if {$pl_ddr_map(1) != 0} {
  ad_ip_parameter ddr4_1 CONFIG.C0.DDR4_DataWidth $pl_ddr_dq_width(1)
  ad_ip_parameter ddr4_1 CONFIG.C0.DDR4_AxiDataWidth $pl_ddr_axi_width(1)
  ad_ip_parameter ddr4_1 CONFIG.C0.DDR4_AxiAddressWidth $pl_ddr_axi_addr_width(1)

  ad_ip_parameter $dac_fifo_name CONFIG.AXI_DATA_WIDTH $pl_ddr_axi_width(1)
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_SIZE 4
  ad_ip_parameter $dac_fifo_name CONFIG.AXI_ADDRESS_LIMIT 0xbfffffff

  delete_bd_objs [get_bd_addr_segs $dac_fifo_name/axi/SEG_ddr4_1_C0_DDR4_ADDRESS_BLOCK]
  create_bd_addr_seg -range 0x40000000 -offset 0x80000000 \
    [get_bd_addr_spaces $dac_fifo_name/axi] \
    [get_bd_addr_segs ddr4_1/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] \
    SEG_ddr4_1_C0_DDR4_ADDRESS_BLOCK
}

ad_ip_instance smartconnect sconnect_0
ad_ip_parameter sconnect_0 CONFIG.NUM_SI 1

#init_calib_done gpio

ad_ip_instance axi_gpio ddr_calib_gpio
ad_ip_parameter ddr_calib_gpio CONFIG.C_IS_DUAL 0
ad_ip_parameter ddr_calib_gpio CONFIG.C_GPIO_WIDTH 2
ad_ip_parameter ddr_calib_gpio CONFIG.C_ALL_INPUTS 1

ad_ip_instance xlconcat ddr_calib_concat
ad_ip_parameter ddr_calib_concat CONFIG.NUM_PORTS 2

# loopback gpio ip inst

ad_ip_instance axi_gpio fmc_gpio_0
ad_ip_parameter fmc_gpio_0 CONFIG.C_IS_DUAL 1
ad_ip_parameter fmc_gpio_0 CONFIG.C_GPIO_WIDTH 32
ad_ip_parameter fmc_gpio_0 CONFIG.C_GPIO2_WIDTH 32

ad_ip_instance axi_gpio fmc_gpio_1
ad_ip_parameter fmc_gpio_1 CONFIG.C_IS_DUAL 0
ad_ip_parameter fmc_gpio_1 CONFIG.C_GPIO_WIDTH 4

# clock monitor

ad_ip_instance axi_clock_monitor clk_monitor_0
ad_ip_parameter clk_monitor_0 CONFIG.NUM_OF_CLOCKS 8
ad_connect clk_mon_0 clk_monitor_0/clock_0
ad_connect clk_mon_1 clk_monitor_0/clock_1
ad_connect clk_mon_2 clk_monitor_0/clock_2
ad_connect clk_mon_3 clk_monitor_0/clock_3
ad_connect clk_mon_4 clk_monitor_0/clock_4
ad_connect clk_mon_5 clk_monitor_0/clock_5
ad_connect ddr4_0/c0_ddr4_ui_clk clk_monitor_0/clock_6
ad_connect ddr4_1/c0_ddr4_ui_clk clk_monitor_0/clock_7

# xcvr

ad_ip_instance axi_xcvrlb axi_xcvrlb_pcie
ad_ip_parameter axi_xcvrlb_pcie CONFIG.CPLL_FBDIV 10
ad_ip_parameter axi_xcvrlb_pcie CONFIG.CPLL_FBDIV_4_5 5
ad_ip_parameter axi_xcvrlb_pcie CONFIG.NUM_OF_LANES 8

ad_ip_instance axi_xcvrlb axi_xcvrlb_fmc
ad_ip_parameter axi_xcvrlb_fmc CONFIG.CPLL_FBDIV 2
ad_ip_parameter axi_xcvrlb_fmc CONFIG.CPLL_FBDIV_4_5 5
ad_ip_parameter axi_xcvrlb_fmc CONFIG.NUM_OF_LANES 10

ad_ip_instance axi_xcvrlb axi_xcvrlb_sfp
ad_ip_parameter axi_xcvrlb_sfp CONFIG.CPLL_FBDIV 2
ad_ip_parameter axi_xcvrlb_sfp CONFIG.CPLL_FBDIV_4_5 5
ad_ip_parameter axi_xcvrlb_sfp CONFIG.NUM_OF_LANES 1

ad_ip_instance axi_xcvrlb axi_xcvrlb_qsfp
ad_ip_parameter axi_xcvrlb_qsfp CONFIG.CPLL_FBDIV 2
ad_ip_parameter axi_xcvrlb_qsfp CONFIG.CPLL_FBDIV_4_5 5
ad_ip_parameter axi_xcvrlb_qsfp CONFIG.NUM_OF_LANES 4

#connections

ad_connect ddr4_ref_0 ddr4_0/C0_SYS_CLK
ad_connect ddr4_rtl_0 ddr4_0/C0_DDR4
ad_connect ddr4_0_rstgen/slowest_sync_clk ddr4_0/c0_ddr4_ui_clk
ad_connect ddr4_0/c0_ddr4_ui_clk_sync_rst ddr4_0_rstgen/ext_reset_in
ad_connect ddr4_0/c0_ddr4_aresetn ddr4_0_rstgen/peripheral_aresetn
ad_connect sys_reset ddr4_0/sys_rst
ad_connect sconnect_0/M00_AXI ddr4_0/C0_DDR4_S_AXI
ad_connect sconnect_0/S00_AXI sys_ps8/M_AXI_HPM0_FPD
ad_connect sconnect_0/aclk ddr4_0/c0_ddr4_ui_clk
ad_connect sys_ps8/maxihpm0_fpd_aclk ddr4_0/c0_ddr4_ui_clk
ad_connect sconnect_0/aresetn ddr4_0_rstgen/peripheral_aresetn

# MIG 0 does not fit the 256 MB low window of M_AXI_HPM0_FPD, place it in the
# high window (0x4_0000_0000) so the PS can access it

create_bd_addr_seg -range [expr 1 << $pl_ddr_axi_addr_width(0)] -offset 0x400000000 \
  [get_bd_addr_spaces sys_ps8/Data] \
  [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] \
  SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK

ad_connect ddr_calib_concat/In0 ddr4_0/c0_init_calib_complete
ad_connect ddr_calib_concat/In1 ddr4_1/c0_init_calib_complete
ad_connect ddr_calib_gpio/gpio_io_i ddr_calib_concat/dout

ad_connect  fmc_gpio_00_i fmc_gpio_0/gpio_io_i
ad_connect  fmc_gpio_00_o fmc_gpio_0/gpio_io_o
ad_connect  fmc_gpio_00_t fmc_gpio_0/gpio_io_t
ad_connect  fmc_gpio_01_i fmc_gpio_0/gpio2_io_i
ad_connect  fmc_gpio_01_o fmc_gpio_0/gpio2_io_o
ad_connect  fmc_gpio_01_t fmc_gpio_0/gpio2_io_t

ad_connect  fmc_gpio_10_i fmc_gpio_1/gpio_io_i
ad_connect  fmc_gpio_10_o fmc_gpio_1/gpio_io_o
ad_connect  fmc_gpio_10_t fmc_gpio_1/gpio_io_t

ad_connect  ref_clk_1 	axi_xcvrlb_pcie/ref_clk
ad_connect  rx_p_3 	axi_xcvrlb_pcie/rx_p
ad_connect  rx_n_3 	axi_xcvrlb_pcie/rx_n
ad_connect  tx_p_3	axi_xcvrlb_pcie/tx_p
ad_connect  tx_n_3 	axi_xcvrlb_pcie/tx_n

ad_connect  ref_clk_0 	axi_xcvrlb_fmc/ref_clk
ad_connect  rx_p_2 	axi_xcvrlb_fmc/rx_p
ad_connect  rx_n_2	axi_xcvrlb_fmc/rx_n
ad_connect  tx_p_2 	axi_xcvrlb_fmc/tx_p
ad_connect  tx_n_2 	axi_xcvrlb_fmc/tx_n

ad_connect  ref_clk_0 	axi_xcvrlb_sfp/ref_clk
ad_connect  rx_p_0 	axi_xcvrlb_sfp/rx_p
ad_connect  rx_n_0 	axi_xcvrlb_sfp/rx_n
ad_connect  tx_p_0 	axi_xcvrlb_sfp/tx_p
ad_connect  tx_n_0 	axi_xcvrlb_sfp/tx_n

ad_connect  ref_clk_0 	axi_xcvrlb_qsfp/ref_clk
ad_connect  rx_p_1 	axi_xcvrlb_qsfp/rx_p
ad_connect  rx_n_1 	axi_xcvrlb_qsfp/rx_n
ad_connect  tx_p_1 	axi_xcvrlb_qsfp/tx_p
ad_connect  tx_n_1 	axi_xcvrlb_qsfp/tx_n

#axi lite connections

ad_cpu_interconnect 0x43A00000 ddr_calib_gpio
ad_cpu_interconnect 0x44b00000 xadc_0
ad_connect sys_cpu_clk xadc_0/s_axi_aclk
ad_connect sys_cpu_resetn xadc_0/s_axi_aresetn

ad_cpu_interconnect 0x43B00000 fmc_gpio_0
ad_cpu_interconnect 0x43C00000 fmc_gpio_1

ad_cpu_interconnect 0x46002000 axi_xcvrlb_pcie
ad_cpu_interconnect 0x46003000 axi_xcvrlb_fmc
ad_cpu_interconnect 0x46004000 axi_xcvrlb_sfp
ad_cpu_interconnect 0x46005000 axi_xcvrlb_qsfp
ad_cpu_interconnect 0x47000000 clk_monitor_0

ad_cpu_interrupt ps-0 mb-0 xadc_0/ip2intc_irpt
