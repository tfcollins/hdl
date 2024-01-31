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

module pristis_top (
  input        clk,
  input        resetn,

  input [31:0] delay, 

  output       meascnt_0_1,
  output       meascnt_2_3,
  output       meascnt_4_5, 
  output       meascnt_6_7
);

  wire meascntx_async;
  wire meascntx_sync;
  wire trigger;
  reg  meascnt = 1;
  reg  mode = 1;
  reg  busy = 0;
  reg [31:0] ctr = 0;
  reg [31:0] max_ctr = 0;
  
  assign meascnt_0_1 = meascnt;
  assign meascnt_2_3 = meascnt;
  assign meascnt_4_5 = meascnt;
  assign meascnt_6_7 = meascnt; 

  pristis_async pristis_async(
    .resetn(resetn),
    .busy(busy),
    .meascntx(meascnt_0_1),
    .meascntx_async(meascntx_async)
  );

  pristis_sync pristis_sync(
    .clk(clk),
    .resetn(resetn),
    .busy(busy),
    .delay(delay),
    .meascntx(meascnt_0_1),
    .edge_trigger(trigger),
    .mode(mode),
    .max_ctr(max_ctr),
    .meascntx_sync(meascntx_sync)
  );

  always @(negedge busy or negedge resetn) begin
    if (!resetn) begin
      mode <= 1'b1;
    end else begin
      mode <= delay != 0 ? 1'b0: 1'b1;
      max_ctr <= delay > 1 ? (delay << 1) - 2: 0;
    end 
  end

  always @(*) begin
    if (!resetn) begin
      meascnt <= 1;
    end else begin
    if (mode) begin
      meascnt <= meascntx_async;
    end else if (!mode && trigger) begin
      meascnt <= meascntx_sync;
    end else begin
      meascnt <= meascnt;
    end
    end
  end
  always @(clk) begin
    if (ctr == 99) begin
      busy <= ~busy;
      ctr <= 1;
    end else begin
      ctr <= ctr + 1;
    end
  end

endmodule
