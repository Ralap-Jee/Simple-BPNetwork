`timescale 1ns/1ns
module u_add_tb();

reg clk;
reg rst_n;
reg [31:0]a;
reg [31:0]b;

wire [31:0]q;

always #10 clk = ~clk;

initial
begin
  clk = 1'b0;
  rst_n = 1'b1;
  a = 32'h0;    
  b = 32'h0;     
  #1
  rst_n = 1'b0;
  #1
  rst_n = 1'b1;
  #10
  a = 32'h3E851EB8;     //0.26
  b = 32'hBD75C28F;     //-0.06
  #100
  a = 32'h3951B717;     //0.0002
  b = 32'h3F744D01;     //0.9543
  
end

u_add u_add_u(
  .clk(clk),
  .rst_n(rst_n),
  .a(a),
  .b(b),
  .q(q)
);

endmodule