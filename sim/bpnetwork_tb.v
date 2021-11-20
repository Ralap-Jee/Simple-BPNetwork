`timescale 1ns/1ns
module bpnetwork_tb();

reg clk;
reg rst_n;
reg en;
reg [8:0]sw;

wire finish;
wire [31:0]result;

always #10 clk = ~clk;

initial
begin
  clk = 1'b0;
  rst_n = 1'b1;
  en = 1'b0;
//  sw = 9'b1_1001_0011;
  sw = 9'b1_0110_1010;
//  sw = 9'b0_1010_1101;
  #1
  rst_n = 1'b0;
  #1
  rst_n = 1'b1;
  #10
  en = 1'b1;
  #100
  en = 1'b0;
  
end

bpnetwork bpnetwork_u(
  .clk(clk),
  .rst_n(rst_n),
  .en(en),
  .sw(sw),
  .finish(finish),
  .result(result)
);

endmodule