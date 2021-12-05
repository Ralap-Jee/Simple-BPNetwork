//lay1 module

module lay1_mod (

	input 					clk,
	input 					rst_n,
	input						en,
	input		 [8:0]		x,		//input sample
	
	output 					valid,
	output 	 [31:0]		y0,	
	output 	 [31:0]		y1,	
	output 	 [31:0]		y2,	
	output 	 [31:0]		y3,
	
	input		 [31:0]		rom_data,
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
			 S5=5'b10101,			//bias add loading
			 S6=5'b11111;			//hold neuron and wait for last sigmoid
			 
parameter sigmoid_Sidle=4'd1, //sigmoid IDLE
			 sigmoid_S0=4'd2,		//sigmoid start & load
			 sigmoid_S1=4'd3;		//sigmoid 

			 
reg[4:0]		state;
reg[4:0]		next_state;
reg[2:0]		neuron;
reg[3:0]		matrix_step;
reg			matrix_finish;
reg[31:0]	matrix_y0;
reg[31:0]	matrix_y1;
reg[31:0]	matrix_y2;
reg[31:0]	matrix_y3;
reg[31:0]	mult_dataa;
reg[31:0]	mult_datab;
wire[31:0]	mult_result;
reg[3:0]		mult_latency;
reg[31:0]	add_dataa;
reg[31:0]	add_datab;
wire[31:0]	add_result;
reg[3:0]		add_latency;
reg[1:0]		rom_latency;
reg			sigmoid_en;
reg[3:0]		sigmoid_state;
reg			sigmoid_finish;
reg[31:0]	sigmoid_x;
reg[31:0]	sigmoid_y0;
reg[31:0]	sigmoid_y1;
reg[31:0]	sigmoid_y2;
reg[31:0]	sigmoid_y3;
reg[5:0]		sigmoid_addr_s;
reg[3:0]		sigmoid_addr_e;
reg[2:0]		sigmoid_addr_f;
wire[6:0]	sigmoid_rom_addr;
wire[31:0]	sigmoid_rom_data;
reg[1:0]		sigmoid_rom_latency;

assign		sigmoid_rom_addr = sigmoid_addr_s + 8*sigmoid_addr_e + sigmoid_addr_f;
assign		valid = (sigmoid_finish==1'b1 && state==S6)? 1'b1:1'b0;
assign		y0 = sigmoid_y0;
assign		y1 = sigmoid_y1;
assign		y2 = sigmoid_y2;
assign		y3 = sigmoid_y3;



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
S0:		if(matrix_finish==1'b1) next_state=S6;
			else	next_state=S1;
S1:		if	(!mult_latency)	next_state=S2;
			else	next_state=S1;
S2:		next_state=S3;
S3:		if (!add_latency)		next_state=S4;
			else	next_state=S3;
S4:		if(matrix_step==4'd8)		next_state=S5;	//这里matrix==8而不是9的原因是：
			else	next_state=S0;								//S4状态总是一个clk，且next_state翻转早于state一个clk
S5:		if	(!rom_latency)	next_state=S3;
			else	next_state=S5;
S6:		if(sigmoid_finish==1'b1)	next_state=Sidle;
			else	next_state=S6;
default: next_state=Sidle;
endcase
end


always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
	matrix_y0 <= 32'h0;
	matrix_y1 <= 32'h0;
	matrix_y2 <= 32'h0;
	matrix_y3 <= 32'h0;
	matrix_finish<= 1'b0;
	neuron <= 3'd0; 
	matrix_step <= 4'd0;
	sigmoid_en <= 1'b0;
	rom_addr <= 6'd0;
	mult_dataa <= 32'h00000000;
	mult_datab <= 32'h00000000;
	mult_latency<=MULT_LATENCY;
	add_latency <=ADD_LATENCY;
	rom_latency <= 2'd2;
end
else
begin 
case(state)
  Sidle: begin
		matrix_y0 <= 32'h0;
		matrix_y1 <= 32'h0;
		matrix_y2 <= 32'h0;
		matrix_y3 <= 32'h0;
		matrix_finish<= 1'b0;
		neuron <= 3'd0;
		matrix_step <= 4'd0;
		sigmoid_en <= 1'b0;
		end
     S0: begin 
	    if (x[8-matrix_step])	mult_dataa <= 32'h3f800000;
		 else		mult_dataa <= 32'h00000000;			//updating...
		 mult_datab <= rom_data;
		 rom_addr <= rom_addr + 6'd4;			//prepare for next multiplitation
		 sigmoid_en <= 1'b0;
		 end
     S1: begin
	    mult_latency <= mult_latency - 1;
		 end
     S2: begin
		 mult_latency <= MULT_LATENCY;		//restore latency first
		 add_dataa <= mult_result;
//		 add_datab <= y;
		 case(neuron)
			0 : add_datab <= matrix_y0;
			1 : add_datab <= matrix_y1;
			2 : add_datab <= matrix_y2;
			3 : add_datab <= matrix_y3;
		 default : add_datab <= add_result;
		 endcase
		 end
     S3: begin 
		 add_latency <= add_latency - 1;
		 end
	  S4: begin
		 add_latency <= ADD_LATENCY;			// restore latency first
//	    y[neuron] <= add_result;

		 case(neuron)
		 0 : matrix_y0 <= add_result;
	 	 1 : matrix_y1 <= add_result;
		 2 : matrix_y2 <= add_result;
		 3 : matrix_y3 <= add_result;
		 endcase

	    if(neuron==2'd3 && matrix_step==4'd9)	begin	//end of all neurons
			matrix_step <= 4'd0;
			neuron <= neuron + 1;
			sigmoid_en <= 1'b1;
			matrix_finish <= 1'b1;
		 end
		 else if (matrix_step == 4'd9)	begin		// end of a neuron
			matrix_step <= 4'd0;
			neuron <= neuron + 1;
			sigmoid_en <= 1'b1;
		 end
		 else if (matrix_step == 4'd8)	begin		// prepare to add bias
			matrix_step <= matrix_step + 1;
			rom_addr <= 6'd40 + neuron;				// it will reading immediately, so it's set with two cycles latency
			rom_latency <= 2'd2;
		 end
		 else matrix_step <= matrix_step + 1;
		 end
	  S5: begin 
		 if(rom_latency==2'd0) begin					//rom_readning need two cycles
			add_dataa <= rom_data;
/*		 	case(neuron)
				0 : add_darab <= matrix_y0;
				1 : add_darab <= matrix_y1;
				2 : add_darab <= matrix_y2;
				3 : add_darab <= matrix_y3;
				default : add_datab <= add_result;
			endcase*/
			add_datab <= add_result;					//a little trick: bias adding is always after a normal adding
			rom_addr <= neuron + 1;						//prepare for neuron No.2 multiplitation
		 end
		 else
			rom_latency <= rom_latency - 1;
		 end
		S6: begin
			neuron <= neuron;								//hold neuron for last sigmoid
		 end
default: begin
	 
		 end
endcase
end


//sigmoid
always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
	sigmoid_state <= 4'd0;
	sigmoid_finish <= 1'b0;
	sigmoid_x <= 32'd0;
	sigmoid_addr_s <= 6'd0;
	sigmoid_addr_e <= 4'd0;
	sigmoid_addr_f <= 3'd0;
	sigmoid_y0 <= 32'd0;
	sigmoid_y1 <= 32'd0;
	sigmoid_y2 <= 32'd0;
	sigmoid_y3 <= 32'd0;
	sigmoid_rom_latency <= 2'd2;
end
else
begin
	case(sigmoid_state)
	sigmoid_Sidle : begin
		sigmoid_finish <= 1'b0;
		if(sigmoid_en)
		begin
			case(neuron)									//neuron number is always 1 bigger 
			1 : sigmoid_x <= matrix_y0;
			2 : sigmoid_x <= matrix_y1;
			3 : sigmoid_x <= matrix_y2;
			4 : sigmoid_x <= matrix_y3;
			endcase
		sigmoid_state <= sigmoid_S0;
		end
	end
	sigmoid_S0 : begin
	
		if(sigmoid_x[31]==1'b1)		sigmoid_addr_s <= 6'd60;
		else		sigmoid_addr_s <= 6'd0;
		
		case(sigmoid_x[30:23])
			8'd124 : begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= 3'b001;
			end
			8'd125 : begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= sigmoid_x[22] + 3'b010;
			end
			8'd126 : begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= sigmoid_x[22:21] + 3'b100;
			end
			8'd127 : begin
				sigmoid_addr_e <= 4'd1;
				sigmoid_addr_f <= sigmoid_x[22:20];
			end
			8'd128 : begin
				sigmoid_addr_e[3:2] <= 2'b00;
				sigmoid_addr_e[1]   <= 1'b1;
				sigmoid_addr_e[0]   <= sigmoid_x[22];
				sigmoid_addr_f 	  <= sigmoid_x[21:19];
			end
			8'd129 : begin
				sigmoid_addr_e[3]   <= 1'b0;
				sigmoid_addr_e[2]   <= 1'b1;
				sigmoid_addr_e[1:0] <= sigmoid_x[22:21];
				sigmoid_addr_f <= sigmoid_x[20:18];
			end
			8'd130 : begin
				sigmoid_addr_e[3]   <= 1'b1;
				sigmoid_addr_e[2:0] <= sigmoid_x[22:20];
				sigmoid_addr_f <= sigmoid_x[19:17];
			end
			default: begin
				sigmoid_addr_e <= 4'd0;
				sigmoid_addr_f <= 3'b0;
			end
		endcase
		
		sigmoid_state <= sigmoid_S1;
		sigmoid_rom_latency <= 2'd2;
		
	end
	sigmoid_S1 : begin
		if(!sigmoid_rom_latency) begin
			sigmoid_finish <= 1'b1;
			case(neuron)
				1 : sigmoid_y0 <= sigmoid_rom_data;
				2 : sigmoid_y1 <= sigmoid_rom_data;
				3 : sigmoid_y2 <= sigmoid_rom_data;
				4 : sigmoid_y3 <= sigmoid_rom_data;
			endcase
			sigmoid_state <= sigmoid_Sidle;
		end
		else
			sigmoid_rom_latency <= sigmoid_rom_latency - 1;
	end
	default : sigmoid_state <= sigmoid_Sidle;
	endcase

end


// Add module with 7 latency
//ADD add_1(
//	.clock			(clk),
//	.dataa			(add_dataa),
//	.datab			(add_datab),
//	.result			(add_result)
//);
u_add add_1(
	.clk				(clk),
	.rst_n			(rst_n),
	.a					(add_dataa),
	.b					(add_datab),
	.q					(add_result)
);

// MULT module with 5 latency
MULT	mult_1(
	.clock			(clk),
	.dataa			(mult_dataa),
	.datab			(mult_datab),
	.result			(mult_result)
);

//sigmoid lut
sigmoid_lut lut_1(
	.clock			(clk),
	.address			(sigmoid_rom_addr),
	.q					(sigmoid_rom_data)
);
endmodule