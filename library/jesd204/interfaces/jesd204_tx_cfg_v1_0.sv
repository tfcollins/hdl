// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2023 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


`ifndef jesd204_tx_cfg_v1_0
`define jesd204_tx_cfg_v1_0

package parameter_structs;

  typedef struct packed {
      bit    portEnabled;
      integer    portWidth;
  }portConfig;

  typedef struct packed {
    // <typeName> <LogicalName> = {<enablement>, <width>}
    portConfig lanes_disable;
    portConfig links_disable;
  }jesd204_tx_cfg_v1_0_port_configuration;

  parameter jesd204_tx_cfg_v1_0_port_configuration jesd204_tx_cfg_v1_0_default_port_configuration = '{lanes_disable:'{1, -1}, links_disable:'{1, -1}};

endpackage

interface jesd204_tx_cfg_v1_0 #(parameter_structs::jesd204_tx_cfg_v1_0_port_configuration port_configuration)();
  logic [port_configuration.lanes_disable.portWidth-1:0] lanes_disable;            // 
  logic [port_configuration.links_disable.portWidth-1:0] links_disable;            // 
  logic [9:0] octets_per_multiframe;                                               // 
  logic [7:0] octets_per_frame;                                                    // 
  logic continuous_cgs;                                                            // 
  logic continuous_ilas;                                                           // 
  logic skip_ilas;                                                                 // 
  logic [7:0] mframes_per_ilas;                                                    // 
  logic disable_char_replacement;                                                  // 
  logic disable_scrambler;                                                         // 
  logic [9:0] device_octets_per_multiframe;                                        // 
  logic [7:0] device_octets_per_frame;                                             // 
  logic [7:0] device_beats_per_multiframe;                                         // 
  logic [7:0] device_lmfc_offset;                                                  // 
  logic device_sysref_oneshot;                                                     // 
  logic device_sysref_disable;                                                     // 

  modport MASTER (
    output lanes_disable, links_disable, octets_per_multiframe, octets_per_frame, continuous_cgs, continuous_ilas, skip_ilas, mframes_per_ilas, disable_char_replacement, disable_scrambler, device_octets_per_multiframe, device_octets_per_frame, device_beats_per_multiframe, device_lmfc_offset, device_sysref_oneshot, device_sysref_disable
    );

  modport SLAVE (
    input lanes_disable, links_disable, octets_per_multiframe, octets_per_frame, continuous_cgs, continuous_ilas, skip_ilas, mframes_per_ilas, disable_char_replacement, disable_scrambler, device_octets_per_multiframe, device_octets_per_frame, device_beats_per_multiframe, device_lmfc_offset, device_sysref_oneshot, device_sysref_disable
    );

  modport MONITOR (
    input lanes_disable, links_disable, octets_per_multiframe, octets_per_frame, continuous_cgs, continuous_ilas, skip_ilas, mframes_per_ilas, disable_char_replacement, disable_scrambler, device_octets_per_multiframe, device_octets_per_frame, device_beats_per_multiframe, device_lmfc_offset, device_sysref_oneshot, device_sysref_disable
    );

endinterface // jesd204_tx_cfg_v1_0

`endif