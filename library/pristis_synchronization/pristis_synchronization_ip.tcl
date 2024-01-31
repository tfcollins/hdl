###############################################################################
## Copyright (C) 2015-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# ip
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create pristis_synchronization
adi_ip_files pristis_synchronization [list \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "pristis_synchronization.v" \
  "pristis_sync.v" \
  "pristis_async.v"]

adi_ip_properties pristis_synchronization

#set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_fan_control} [ipx::current_core]

set cc [ipx::current_core]

ipx::save_core $cc

