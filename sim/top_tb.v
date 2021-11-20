`timescale 1ps/1ps
module top_tb();

reg clk;
reg rst_n;
reg key;
reg [8:0]sw;


wire [6:0]seg;

always #10 clk = ~clk;

initial
begin
  clk = 1'b0;
  rst_n = 1'b1;
  key = 1'b1;
//  sw = 9'b1_1001_0011;
  sw = 9'b1_0110_1010;
//  sw = 9'b0_1010_1101;
  #1
  rst_n = 1'b0;
  #1
  rst_n = 1'b1;
  #10
  key = 1'b0;
  #100
  key = 1'b1;
  
end

top top_u(
  .clk(clk),
  .rst_n(rst_n),
  .key(key),
  .sw(sw),

  .led(seg)
);

endmodule