// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module pristis_sync (
  input        clk,
  input        resetn,

  input        busy,
  input [31:0] delay, 
  input        meascntx,
  input        mode,
  input [31:0] max_ctr,


  output       edge_trigger,
  output       meascntx_sync
);

  wire       trigger;
  wire       edge_busy;
  reg        temp_busy = 0;
  reg        temp_trigger = 0;
  reg        enable_delay = 0;
  reg        enable_sync = 0;
  reg        meascnt0 = 1;
  reg [31:0] ctr = 0;

  assign trigger = (enable_sync) ? 1: 0;
  assign edge_busy = temp_busy && !busy;
  assign edge_trigger = temp_trigger && !trigger;
  assign meascntx_sync = (meascntx || !meascntx) ? meascnt0: 1;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      temp_busy <= 0;
      temp_trigger <= 0;
      enable_delay <= 0;
      enable_sync <= 0;
      meascnt0 <= 1;
      ctr <= 0;
    end else begin
      temp_busy <= busy;
      temp_trigger <= trigger;


      if (edge_busy && !mode) begin
        enable_delay <= 1;
      end
      if (!mode) begin  
        if (!mode && (edge_busy || enable_delay)) begin
          if (ctr == max_ctr)begin
            enable_sync <= 1;
          end else begin
            enable_sync = 0;
            ctr <= ctr + 1;
          end
        end
        if (trigger) begin
          if (meascnt0 == meascntx) begin
            meascnt0 <= ~meascnt0;
          end
          enable_delay <= 0;
          enable_sync <= 0;
          ctr <= 0;
        end
      end
    end
  end

endmodule
