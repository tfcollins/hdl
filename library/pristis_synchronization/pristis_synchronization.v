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
  input         dac_reset_n,
  //input         busy,
  input         sync_clk,

  output        busy_display,
  output        meascnt_0_1,
  output        meascnt_2_3,
  output        meascnt_4_5, 
  output        meascnt_6_7,

  //axi interface
  input         s_axi_aclk,
  input         s_axi_aresetn,
  input         s_axi_awvalid,
  input  [15:0] s_axi_awaddr,
  input  [ 2:0] s_axi_awprot,
  output        s_axi_awready,
  input         s_axi_wvalid,
  input  [31:0] s_axi_wdata,
  input  [ 3:0] s_axi_wstrb,
  output        s_axi_wready,
  output        s_axi_bvalid,
  output [ 1:0] s_axi_bresp,
  input         s_axi_bready,
  input         s_axi_arvalid,
  input  [15:0] s_axi_araddr,
  input  [ 2:0] s_axi_arprot,
  output        s_axi_arready,
  output        s_axi_rvalid,
  output [ 1:0] s_axi_rresp,
  output [31:0] s_axi_rdata,
  input         s_axi_rready
);

  wire       meascntx_async;
  wire       meascntx_sync;
  wire       trigger;
  reg [31:0] delay = 0;
  reg        meascnt = 1;
  reg        mode = 1;
  reg        busy = 0;
  reg [31:0] ctr = 0;
  reg [31:0] max_ctr = 0;

  wire        up_rreq;
  wire [ 7:0] up_raddr;
  wire        up_wreq;
  wire [ 7:0] up_waddr;
  wire [31:0] up_wdata;
  reg         up_wack = 0;
  reg  [31:0] up_rdata = 0;
  reg         up_rack = 0;
  reg         resetn = 1;
  
  assign busy_display = busy;
  assign meascnt_0_1 = meascnt;
  assign meascnt_2_3 = mode;
  assign meascnt_4_5 = meascnt;
  assign meascnt_6_7 = meascnt; 

  up_axi #(
    .AXI_ADDRESS_WIDTH(10)
  ) i_up_axi (
    .up_rstn (s_axi_aresetn),
    .up_clk (s_axi_aclk),
    .up_axi_awvalid (s_axi_awvalid),
    .up_axi_awaddr (s_axi_awaddr),
    .up_axi_awready (s_axi_awready),
    .up_axi_wvalid (s_axi_wvalid),
    .up_axi_wdata (s_axi_wdata),
    .up_axi_wstrb (s_axi_wstrb),
    .up_axi_wready (s_axi_wready),
    .up_axi_bvalid (s_axi_bvalid),
    .up_axi_bresp (s_axi_bresp),
    .up_axi_bready (s_axi_bready),
    .up_axi_arvalid (s_axi_arvalid),
    .up_axi_araddr (s_axi_araddr),
    .up_axi_arready (s_axi_arready),
    .up_axi_rvalid (s_axi_rvalid),
    .up_axi_rresp (s_axi_rresp),
    .up_axi_rdata (s_axi_rdata),
    .up_axi_rready (s_axi_rready),
    .up_wreq (up_wreq),
    .up_waddr (up_waddr),
    .up_wdata (up_wdata),
    .up_wack (up_wack),
    .up_rreq (up_rreq),
    .up_raddr (up_raddr),
    .up_rdata (up_rdata),
    .up_rack (up_rack));

//asynchronous
  pristis_async pristis_async(
    .resetn(dac_reset_n),
    .busy(busy),
    .meascntx(meascnt_0_1),
    .meascntx_async(meascntx_async)
  );

//synchronous
  pristis_sync pristis_sync(
    .clk(sync_clk),
    .resetn(dac_reset_n),
    .busy(busy),
    .delay(delay),
    .meascntx(meascnt_0_1),
    .edge_trigger(trigger),
    .mode(mode),
    .max_ctr(max_ctr),
    .meascntx_sync(meascntx_sync)
  );

// output switching mode (asynchronous or synchronous)
  always @(negedge busy or negedge dac_reset_n) begin
    if (!dac_reset_n) begin
      mode <= 1'b1;
    end else begin
      mode <= delay != 0 ? 1'b0: 1'b1;
      max_ctr <= delay > 1 ? (delay << 1) - 2: 0;
    end 
  end

// output
  always @(*) begin
    if (!dac_reset_n) begin
      meascnt <= 1;
    end else begin
      if (mode) begin
        meascnt <= meascntx_async;
      end else if (!mode && trigger) begin
        meascnt <= meascntx_sync;
      end
    end
  end

//register write
  always @(posedge s_axi_aclk) begin
    if (resetn == 1'b0) begin
      delay <= 0;
    end else begin
      if ((up_wreq == 1'b1) && (up_waddr == 8'h00)) begin
        delay <= up_wdata;
      end
    end
  end

//register write reset
  always @(posedge s_axi_aclk) begin
    if (s_axi_aresetn == 1'b0) begin
      up_wack <= 'd0;
      resetn <= 1'd0;
    end else if (dac_reset_n == 0) begin
      up_wack <= up_wreq;
      resetn <= dac_reset_n;
    end else begin
      up_wack <= up_wreq;
      resetn <= 1'd1;
    end
  end

//register read
  always @(posedge s_axi_aclk) begin
    if (s_axi_aresetn == 1'b0) begin
      up_rack <= 'd0;
      up_rdata <= 'd0;
    end else begin
      up_rack <= up_rreq;
      if ((up_rreq == 1'b1) && (up_raddr == 8'h00)) begin
        up_rdata <= delay;
    end
      else if ((up_rreq == 1'b1) && (up_raddr == 8'h01))begin
        up_rdata <= 'h112233;
      end
    end
  end

  //simulated input
  always @(posedge s_axi_aclk) begin
    if (ctr == 50) begin
      busy <= ~busy;
      ctr <= 1;
    end else begin
      ctr <= ctr + 1;
    end
  end

endmodule
