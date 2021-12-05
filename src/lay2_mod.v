//lay2 module

module lay2_mod (

	input 					clk,
	input 					rst_n,
	input						en,
	input 	[31:0]		x0,	
	input 	[31:0]		x1,	
	input 	[31:0]		x2,	
	input 	[31:0]		x3,
	
	output reg				valid,
	output reg[31:0]		y,

	input		[31:0]		rom_data,
	output reg[5:0]		rom_addr
);

parameter MULT_LATENCY = 4'd4,	//mult latency is 5, so it's set as 4 because of a reg delay
			 ADD_LATENCY  = 4'd4;	//add latency is 5

// state code			 
parameter Sidle=5'b00000,		//IDLE
			 S0=5'b00001,			//load data & mult
			 S1=5'b00010,			//mult waite
			 S2=5'b00100,			//load data & add
			 S3=5'b01000,			//add waite
			 S4=5'b10000,			//crossroad judgement
			 S5=5'b10001,			//bias add loading
			 S6=5'b10010,			//bias adding wait
			 S7=5'b10100,			//sigmoid
			 S8=5'b11000,			//wait
			 S9=5'b11111;			//finish

			 
reg[4:0]		state;
reg[4:0]		next_state;
reg[1:0]		matrix_step;
reg[31:0]	matrix_y;
reg[31:0]	mult_dataa;
reg[31:0]	mult_datab;
wire[31:0]	mult_result;
reg[3:0]		mult_latency;
reg[31:0]	add_dataa;
reg[31:0]	add_datab;
wire[31:0]	add_result;
reg[3:0]		add_latency;
reg[5:0]		sigmoid_addr_s;
reg[3:0]		sigmoid_addr_e;
reg[2:0]		sigmoid_addr_f;
wire[6:0]	sigmoid_rom_addr;
wire[31:0]	sigmoid_rom_data;
reg[1:0]		rom_latency;

assign		sigmoid_rom_addr = sigmoid_addr_s + 8*sigmoid_addr_e + sigmoid_addr_f;


always @(posedge clk or negedge rst_n) 
begin
	if(!rst_n) state<=Sidle;
		//current_state <= Sidle;
	else state<=next_state;
		//current_state <= next_state;	
end

// Next-state combinational logic
always @*
begin
case(state)
Sidle:	if (en)	next_state=S0;
			else	next_state=Sidle;
S0:		next_state=S1;
S1:		if	(!mult_latency)	next_state=S2;
			else	next_state=S1;
S2:		next_state=S3;
S3:		if (!add_latency)		next_state=S4;
			else	next_state=S3;
S4:		if(matrix_step==2'd3)		next_state=S5;
			else	next_state=S0;
S5:		if (!rom_latency)		next_state=S6;
			else	next_state=S5;
S6:		if (!add_latency)		next_state=S7;
			else	next_state=S6;
S7:		next_state=S8;
S8:		if (!rom_latency)		next_state=Sidle;
			else	next_state=S8;
default: next_state=Sidle;
endcase
end


always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
	matrix_y <= 32'h0;
	valid<= 1'b0;
	matrix_step <= 2'd0;
	rom_addr <= 6'd36;
	mult_dataa <= x0;
	mult_datab <= 32'h00000000;
	mult_latency<=MULT_LATENCY;
	add_latency <=ADD_LATENCY;
	rom_latency <= 2'd2;
end
else
begin 
case(state)
  Sidle: begin
		matrix_y <= 32'h0;
		valid<= 1'b0;
		matrix_step <= 2'd0;
		rom_addr <= 6'd36;
		mult_dataa <= x0;
		mult_datab <= 32'h00000000;
		mult_latency<=MULT_LATENCY;
		add_latency <=ADD_LATENCY;
		rom_latency <= 2'd2;
		 end
     S0: begin 
//	    if (x[matrix_step])	mult_dataa <= 32'h3f800000;
//		 else		mult_dataa <= 32'h00000000;			//updating...
		 if 		(matrix_step==1)		mult_dataa <= x1;
		 else if (matrix_step==2)		mult_dataa <= x2;
		 else if (matrix_step==3)		mult_dataa <= x3;
		 else									mult_dataa <= x0;
		 mult_datab <= rom_data;
		 rom_addr <= rom_addr + 6'd1;			//prepare for next multiplitation
		 end
     S1: begin
	    mult_latency <= mult_latency - 1;
		 end
     S2: begin
		 mult_latency <= MULT_LATENCY;		//restore latency first
		 add_dataa <= mult_result;
		 add_datab <= matrix_y;
		 end
     S3: begin 
		 add_latency <= add_latency - 1;
		 end
	  S4: begin
		 add_latency <= ADD_LATENCY;			// restore latency first
	    matrix_y <= add_result;
		 matrix_step <= matrix_step + 1;
		 if(matrix_step==2'd3) begin
			rom_addr <= 6'd44;
			rom_latency <= 2'd2;
		 end
		 end
	  S5: begin 
		 if(!rom_latency) begin
			add_dataa <= rom_data;
			add_datab <= matrix_y;
		 end
		 else
			rom_latency <= rom_latency - 1;
		 end
	  S6: begin 
		 add_latency <= add_latency - 1;
		 end
	  S7: begin 
	    add_latency <= ADD_LATENCY;			// restore latency first
		 rom_latency <= 2'd2;
//		 sigmoid_rom_latency <= 2'd2;			// sigmoid_rom_latency can be saved by sharing rom_latency
//		 y <= add_result;
//		 valid <= 1'b1;
		 
		 if(add_result[31]==1'b1)		sigmoid_addr_s <= 6'd60;			// sigmoid
		else		sigmoid_addr_s <= 6'd0;
		
		case(add_result[30:23])
			8'd124 : begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= 3'b001;
			end
			8'd125 : begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= add_result[22] + 3'b010;
			end
			8'd126 : begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= add_result[22:21] + 3'b100;
			end
			8'd127 : begin
				sigmoid_addr_e <= 4'd1;
				sigmoid_addr_f <= add_result[22:20];
			end
			8'd128 : begin
				sigmoid_addr_e[3:2] <= 2'b00;
				sigmoid_addr_e[1]   <= 1'b1;
				sigmoid_addr_e[0]   <= add_result[22];
				sigmoid_addr_f 	  <= add_result[21:19];
			end
			8'd129 : begin
				sigmoid_addr_e[3]   <= 1'b0;
				sigmoid_addr_e[2]   <= 1'b1;
				sigmoid_addr_e[1:0] <= add_result[22:21];
				sigmoid_addr_f <= add_result[20:18];
			end
			8'd130 : begin
				sigmoid_addr_e[3]   <= 1'b1;
				sigmoid_addr_e[2:0] <= add_result[22:20];
				sigmoid_addr_f <= add_result[19:17];
			end
			default: begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= 3'b0;
			end
		endcase
		 
		 end
		S8: begin 
			if(!rom_latency) begin
				y <= sigmoid_rom_data;
				valid <= 1'b1;
			end
			else
				rom_latency <= rom_latency - 1;
		 end
default: begin
	 
		 end
endcase
end


// Add module with 7 latency
//ADD add_2(
//	.clock			(clk),
//	.dataa			(add_dataa),
//	.datab			(add_datab),
//	.result			(add_result)
//);
u_add add_2(
	.clk				(clk),
	.rst_n			(rst_n),
	.a					(add_dataa),
	.b					(add_datab),
	.q					(add_result)
);

// MULT module with 5 latency
MULT	mult_2(
	.clock			(clk),
	.dataa			(mult_dataa),
	.datab			(mult_datab),
	.result			(mult_result)
);

//sigmoid lut
sigmoid_lut lut_2(
	.clock			(clk),
	.address			(sigmoid_rom_addr),
	.q					(sigmoid_rom_data)
);
endmodule