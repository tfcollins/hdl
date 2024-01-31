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


`ifndef jesd204_rx_status_v1_0
`define jesd204_rx_status_v1_0

package parameter_structs;

  typedef struct packed {
      bit    portEnabled;
      integer    portWidth;
  }portConfig;

  typedef struct packed {
    // <typeName> <LogicalName> = {<enablement>, <width>}
    portConfig lane_cgs_state;
    portConfig lane_emb_state;
    portConfig lane_frame_align;
    portConfig lane_ifs_ready;
    portConfig lane_latency_ready;
    portConfig lane_latency;
    portConfig err_statistics_cnt;
    portConfig synth_params0;
    portConfig synth_params1;
    portConfig synth_params2;
  }jesd204_rx_status_v1_0_port_configuration;

  parameter jesd204_rx_status_v1_0_port_configuration jesd204_rx_status_v1_0_default_port_configuration = '{lane_cgs_state:'{1, -1}, lane_emb_state:'{1, -1}, lane_frame_align:'{1, -1}, lane_ifs_ready:'{1, -1}, lane_latency_ready:'{1, -1}, lane_latency:'{1, -1}, err_statistics_cnt:'{1, -1}, synth_params0:'{1, -1}, synth_params1:'{1, -1}, synth_params2:'{1, -1}};

endpackage

interface jesd204_rx_status_v1_0 #(parameter_structs::jesd204_rx_status_v1_0_port_configuration port_configuration)();
  logic [2:0] ctrl_state;                                                                    // 
  logic [port_configuration.lane_cgs_state.portWidth-1:0] lane_cgs_state;                    // 
  logic [port_configuration.lane_emb_state.portWidth-1:0] lane_emb_state;                    // 
  logic [port_configuration.lane_frame_align.portWidth-1:0] lane_frame_align;                // 
  logic [port_configuration.lane_ifs_ready.portWidth-1:0] lane_ifs_ready;                    // 
  logic [port_configuration.lane_latency_ready.portWidth-1:0] lane_latency_ready;            // 
  logic [port_configuration.lane_latency.portWidth-1:0] lane_latency;                        // 
  logic [port_configuration.err_statistics_cnt.portWidth-1:0] err_statistics_cnt;            // 
  logic [port_configuration.synth_params0.portWidth-1:0] synth_params0;                      // 
  logic [port_configuration.synth_params1.portWidth-1:0] synth_params1;                      // 
  logic [port_configuration.synth_params2.portWidth-1:0] synth_params2;                      // 

  modport MASTER (
    output ctrl_state, lane_cgs_state, lane_emb_state, lane_frame_align, lane_ifs_ready, lane_latency_ready, lane_latency, err_statistics_cnt, synth_params0, synth_params1, synth_params2
    );

  modport SLAVE (
    input ctrl_state, lane_cgs_state, lane_emb_state, lane_frame_align, lane_ifs_ready, lane_latency_ready, lane_latency, err_statistics_cnt, synth_params0, synth_params1, synth_params2
    );

  modport MONITOR (
    input ctrl_state, lane_cgs_state, lane_emb_state, lane_frame_align, lane_ifs_ready, lane_latency_ready, lane_latency, err_statistics_cnt, synth_params0, synth_params1, synth_params2
    );

endinterface // jesd204_rx_status_v1_0

`endif