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


`ifndef if_gt_rx_v1_0
`define if_gt_rx_v1_0

interface if_gt_rx_v1_0();
  logic rx_p;                                            // 
  logic rx_n;                                            // 
  logic rx_rst;                                          // 
  logic rx_rst_m;                                        // 
  logic rx_pll_rst;                                      // 
  logic rx_gt_rst;                                       // 
  logic rx_gt_rst_m;                                     // 
  logic rx_pll_locked;                                   // 
  logic rx_pll_locked_m;                                 // 
  logic rx_user_ready;                                   // 
  logic rx_user_ready_m;                                 // 
  logic rx_rst_done;                                     // 
  logic rx_rst_done_m;                                   // 
  logic rx_out_clk;                                      // 
  logic rx_clk;                                          // 
  logic rx_sysref;                                       // 
  logic rx_sync;                                         // 
  logic rx_sof;                                          // 
  logic [31:0] rx_data;                                   // 
  logic rx_ip_rst;                                       // 
  logic [3:0] rx_ip_sof;                                 // 
  logic [31:0] rx_ip_data;                                // 
  logic rx_ip_sysref;                                    // 
  logic rx_ip_sync;                                      // 
  logic rx_ip_rst_done;                                  // 

  modport MASTER (
    input rx_rst, rx_pll_rst, rx_gt_rst, rx_pll_locked, rx_user_ready, rx_rst_done, rx_out_clk, rx_sync, rx_sof, rx_data, rx_ip_rst, rx_ip_sysref, rx_ip_rst_done, 
    output rx_p, rx_n, rx_rst_m, rx_gt_rst_m, rx_pll_locked_m, rx_user_ready_m, rx_rst_done_m, rx_clk, rx_sysref, rx_ip_sof, rx_ip_data, rx_ip_sync
    );

  modport SLAVE (
    input rx_p, rx_n, rx_rst_m, rx_gt_rst_m, rx_pll_locked_m, rx_user_ready_m, rx_rst_done_m, rx_clk, rx_sysref, rx_ip_sof, rx_ip_data, rx_ip_sync, 
    output rx_rst, rx_pll_rst, rx_gt_rst, rx_pll_locked, rx_user_ready, rx_rst_done, rx_out_clk, rx_sync, rx_sof, rx_data, rx_ip_rst, rx_ip_sysref, rx_ip_rst_done
    );

  modport MONITOR (
    input rx_p, rx_n, rx_rst, rx_rst_m, rx_pll_rst, rx_gt_rst, rx_gt_rst_m, rx_pll_locked, rx_pll_locked_m, rx_user_ready, rx_user_ready_m, rx_rst_done, rx_rst_done_m, rx_out_clk, rx_clk, rx_sysref, rx_sync, rx_sof, rx_data, rx_ip_rst, rx_ip_sof, rx_ip_data, rx_ip_sysref, rx_ip_sync, rx_ip_rst_done
    );

endinterface // if_gt_rx_v1_0

`endif