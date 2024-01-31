`timescale 1ns / 1ps

module tb_pristis ();
  logic clk;
  logic resetn;
  //logic busy;
  logic [31:0] delay; 
  logic meascnt_0_1;
  logic meascnt_2_3;
  logic meascnt_4_5; 
  logic meascnt_6_7;

  pristis_top pristis_top(
    .clk(clk),
    .resetn(resetn),
    //.busy(busy),
    .delay(delay), 
    .meascnt_0_1(meascnt_0_1),
    .meascnt_2_3(meascnt_2_3),
    .meascnt_4_5(meascnt_4_5), 
    .meascnt_6_7(meascnt_6_7)
  );

  initial begin
    // clock source
    clk = 0;
    fork
      forever #2.5 clk = ~clk;
    join_none
    // disable reset
    resetn = 1;
    delay = 32'd10;
    for (int i = 0; i < 10; i++) begin
      //busy = 0;
      #700;
      delay = 0;
      #500;
      //busy = 1;
      #300;
      //busy = 0; 
      
      //busy = 0;
      #200;
      //delay = i * 10 + 10;
      delay = i + 1;
      #500;
      //busy = 1;
      #300;
      //busy = 0;

      //busy = 0;
      #200;
      //delay = i * 10 + 10;
      delay = i + 1;
      #500;
      //busy = 1;
      #300;
     // busy = 0;
    end
  end
endmodule