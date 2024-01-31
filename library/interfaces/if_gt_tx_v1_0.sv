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


`ifndef if_gt_tx_v1_0
`define if_gt_tx_v1_0

interface if_gt_tx_v1_0();
  logic tx_p;                                            // 
  logic tx_n;                                            // 
  logic tx_rst;                                          // 
  logic tx_rst_m;                                        // 
  logic tx_pll_rst;                                      // 
  logic tx_gt_rst;                                       // 
  logic tx_gt_rst_m;                                     // 
  logic tx_pll_locked;                                   // 
  logic tx_pll_locked_m;                                 // 
  logic tx_user_ready;                                   // 
  logic tx_user_ready_m;                                 // 
  logic tx_rst_done;                                     // 
  logic tx_rst_done_m;                                   // 
  logic tx_out_clk;                                      // 
  logic tx_clk;                                          // 
  logic tx_sysref;                                       // 
  logic tx_sync;                                         // 
  logic [31:0] tx_data;                                   // 
  logic tx_ip_rst;                                       // 
  logic [31:0] tx_ip_data;                                // 
  logic tx_ip_sysref;                                    // 
  logic tx_ip_sync;                                      // 
  logic tx_ip_rst_done;                                  // 

  modport MASTER (
    input tx_p, tx_n, tx_rst, tx_pll_rst, tx_gt_rst, tx_pll_locked, tx_user_ready, tx_rst_done, tx_out_clk, tx_ip_rst, tx_ip_data, tx_ip_sysref, tx_ip_sync, tx_ip_rst_done, 
    output tx_rst_m, tx_gt_rst_m, tx_pll_locked_m, tx_user_ready_m, tx_rst_done_m, tx_clk, tx_sysref, tx_sync, tx_data
    );

  modport SLAVE (
    input tx_rst_m, tx_gt_rst_m, tx_pll_locked_m, tx_user_ready_m, tx_rst_done_m, tx_clk, tx_sysref, tx_sync, tx_data, 
    output tx_p, tx_n, tx_rst, tx_pll_rst, tx_gt_rst, tx_pll_locked, tx_user_ready, tx_rst_done, tx_out_clk, tx_ip_rst, tx_ip_data, tx_ip_sysref, tx_ip_sync, tx_ip_rst_done
    );

  modport MONITOR (
    input tx_p, tx_n, tx_rst, tx_rst_m, tx_pll_rst, tx_gt_rst, tx_gt_rst_m, tx_pll_locked, tx_pll_locked_m, tx_user_ready, tx_user_ready_m, tx_rst_done, tx_rst_done_m, tx_out_clk, tx_clk, tx_sysref, tx_sync, tx_data, tx_ip_rst, tx_ip_data, tx_ip_sysref, tx_ip_sync, tx_ip_rst_done
    );

endinterface // if_gt_tx_v1_0

`endif