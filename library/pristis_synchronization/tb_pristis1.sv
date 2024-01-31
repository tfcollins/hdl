`timescale 1ns / 1ps

module tb_pristis ();
  logic clk;
  logic resetn;
  //logic busy;
  logic [31:0] up_wdata; 
  logic meascnt_0_1;
  logic meascnt_2_3;
  logic meascnt_4_5; 
  logic meascnt_6_7;
  logic up_awvalid = 1;
  logic up_wvalid = 1;

  pristis_top pristis_top(
    .s_axi_aclk(clk),
    .dac_reset_n(resetn),
    //.busy(busy),
    .s_axi_wdata(up_wdata), 
    .s_axi_awvalid(up_awvalid),
    .s_axi_wvalid(up_wvalid),
    .s_axi_awaddr(0),
    .meascnt_0_1(meascnt_0_1),
    .meascnt_2_3(meascnt_2_3),
    .meascnt_4_5(meascnt_4_5), 
    .meascnt_6_7(meascnt_6_7)
  );

  initial begin
    // clock source
    clk = 0;
    fork
      forever #5 clk = ~clk;
    join_none
    // disable reset
    resetn = 1;
    up_awvalid = 1;
    up_wvalid = 1;
    up_wdata = 32'd0;
    for (int i = 0; i < 1; i++) begin
      //busy = 0;
      up_awvalid = 0;
      up_wvalid = 0;
      #200;
      up_awvalid = 1;
      up_wvalid = 1;
      up_wdata = 0;
      #500;
      //busy = 1;
      #300;
      //busy = 0; 
      
      //busy = 0;
      #200;
      //up_wdata = i * 10 + 10;
      up_awvalid = 1;
      up_wvalid = 1;
      up_wdata = 1 + 1;
      #500;
      //busy = 1;
      #300;
      //busy = 0;

      //busy = 0;
      #200;
      //up_wdata = i * 10 + 10;
      up_awvalid = 1;
      up_wvalid = 1;
      up_wdata = 1 + 1;
      #500;
      //busy = 1;
      #300;
     // busy = 0;
    end
  end
endmodule