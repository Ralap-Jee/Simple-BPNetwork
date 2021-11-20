`timescale 1ns/1ns
module lay1_tb();

reg clk;
reg rst_n;
reg en;
reg [8:0]x;
reg [31:0]rom_data;

wire valid;
wire [31:0]y0;
wire [31:0]y1;
wire [31:0]y2;
wire [31:0]y3;
wire [5:0]rom_addr;

always #10 clk = ~clk;

initial
begin
  clk = 1'b0;
  rst_n = 1'b1;
  en = 1'b0;
  x = 9'b1_0011_1010;
  rom_data = 32'h3A580000;
  #1
  rst_n = 1'b0;
  #1
  rst_n = 1'b1;
  #10
  en = 1'b1;
  
end

lay1_mod lay1_mod_u(
  .clk(clk),
  .rst_n(rst_n),
  .en(en),
  .x(x),
  .rom_data(rom_data),
  .valid(valid),
  .y0(y0),
  .y1(y1),
  .y2(y2),
  .y3(y3),
  .rom_addr(rom_addr)
);

endmodule