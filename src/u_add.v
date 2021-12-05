module u_add(
	input 		clk,
	input 		rst_n,
	input[31:0]	a,
	input[31:0] b,
	
//	output reg[31:0]result
	output[31:0]q
);

wire[1:0]	s;
reg[3:0]		int;
reg[22:0]	dot;
reg[31:0]	a_delay;
reg[3:0]		int_delay;
reg[3:0]		int_delay1;
reg[22:0]	dot_delay;
reg[22:0]	dot_delay1;
reg[3:0]		int_add;
reg[22:0]	dot_add;
reg[4:0]		int_add_temp;
reg[23:0]	dot_add_temp;
reg[31:0]	result;
wire[31:0]	data;
reg[3:0]		data_index;

assign	s	=	{b[31],a[31]};
assign	data = (data_index==4'd0)? a:b;
assign	q	=	(data_index==4'd5)? result:q;

always@(posedge clk)
begin
a_delay   <= a;
int_delay <= int;
dot_delay <= dot;
int_delay1<= int_delay;
dot_delay1<= dot_delay;
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	data_index <= 4'd0;
else if(a!=a_delay)
	data_index <= 4'd1;
else if(data_index < 4'd5 && data_index > 4'd0)
	data_index <= data_index + 4'd1;
else
	data_index <= 4'd0;
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
	int_add <= 4'd0;
	dot_add <= 23'd0;
	int_add_temp <= 5'd0;
	dot_add_temp <= 24'd0;
	result[31]	  <= 1'b0;
end
else 
		case(s)
		2'b00: begin
			if(dot_add_temp[23]==1'b1)	begin
				int_add <= int_delay1 + int_delay + 1;
				dot_add <= dot_delay1 + dot_delay;
			end
			else begin
				int_add <= int_delay1 + int_delay;
				dot_add <= dot_delay1 + dot_delay;
			end
			dot_add_temp <= dot + dot_delay;
			result[31]	  <= 1'b0;
		end
		2'b11: begin
			if(dot_add_temp[23]==1'b1)	begin
				int_add <= int_delay1 + int_delay + 1;
				dot_add <= dot_delay1 + dot_delay;
			end
			else begin
				int_add <= int_delay1 + int_delay;
				dot_add <= dot_delay1 + dot_delay;
			end
			dot_add_temp <= dot + dot_delay;
			result[31]	  <= 1'b1;
		end
		2'b10: begin
			case({int_add_temp[4],dot_add_temp[23]})
			2'b00:begin
				int_add <= int_delay1 - int_delay;
				dot_add <= dot_delay1 - dot_delay;
				result[31]	  <= 1'b0;
			end
			2'b11:begin
				int_add <= int_delay - int_delay1;
				dot_add <= dot_delay - dot_delay1;
				result[31]	  <= 1'b1;
			end
			2'b10:begin
				int_add <= int_delay - int_delay1 - 1;
				dot_add <= {1'b1,dot_delay} - dot_delay1;
				result[31]	  <= 1'b1;
			end
			2'b01:begin
				int_add <= int_delay1 - int_delay - 1;
				dot_add <= {1'b1,dot_delay1} - dot_delay;
				result[31]	  <= 1'b0;
			end
			endcase
			dot_add_temp <= dot_delay - dot;
			int_add_temp <= int_delay - int;
		end
		2'b01: begin
			case({int_add_temp[4],dot_add_temp[23]})
			2'b00:begin
				int_add <= int_delay - int_delay1;
				dot_add <= dot_delay - dot_delay1;
				result[31]	  <= 1'b0;
			end
			2'b11:begin
				int_add <= int_delay1 - int_delay;
				dot_add <= dot_delay1 - dot_delay;
				result[31]	  <= 1'b1;
			end
			2'b10:begin
				int_add <= int_delay1 - int_delay - 1;
				dot_add <= {1'b1,dot_delay1} - dot_delay;
				result[31]	  <= 1'b1;
			end
			2'b01:begin
				int_add <= int_delay - int_delay1 - 1;
				dot_add <= {1'b1,dot_delay} - dot_delay1;
				result[31]	  <= 1'b0;
			end
			endcase
			dot_add_temp <= dot - dot_delay;
			int_add_temp <= int - int_delay;
		end
		endcase
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
	int <= 4'd0;
	dot <= 23'd0;
end
else
begin
		case(data[30:23])
			8'd115 : begin
				int <= 4'd0;
				dot[22:11]<=12'b000000000001;
				dot[10:0] <= data[22:12];
			end
			8'd116 : begin
				int <= 4'd0;
				dot[22:12]<=11'b00000000001;
				dot[11:0] <= data[22:11];
			end
			8'd117 : begin
				int <= 4'd0;
				dot[22:13]<=10'b0000000001;
				dot[12:0] <= data[22:10];
			end
			8'd118 : begin
				int <= 4'd0;
				dot[22:14]<=9'b000000001;
				dot[13:0] <= data[22:9];
			end
			8'd119 : begin
				int <= 4'd0;
				dot[22:15]<=8'b00000001;
				dot[14:0] <= data[22:8];
			end
			8'd120 : begin
				int <= 4'd0;
				dot[22:16]<=7'b0000001;
				dot[15:0] <= data[22:7];
			end
			8'd121 : begin
				int <= 4'd0;
				dot[22:17]<=6'b000001;
				dot[16:0] <= data[22:6];
			end
			8'd122 : begin
				int <= 4'd0;
				dot[22:18]<=5'b00001;
				dot[17:0] <= data[22:5];
			end
			8'd123 : begin
				int <= 4'd0;
				dot[22:19]<=4'b0001;
				dot[18:0] <= data[22:4];
			end
			8'd124 : begin
				int <= 4'd0;
				dot[22:20]<=3'b001;
				dot[19:0] <= data[22:3];
			end
			8'd125 : begin
				int <= 4'd0;
				dot[22:21]<=2'b01;
				dot[20:0] <= data[22:2];
			end
			8'd126 : begin
				int <= 4'd0;
				dot[22]	<= 1'b1;
				dot[21:0]<= data[22:1];
			end
			8'd127 : begin
				int <= 4'd1;
				dot <= data[22:0];
			end
			8'd128 : begin
				int[3:2] <= 2'b00;
				int[1]   <= 1'b1;
				int[0]   <= data[22];
				dot[0]	<= 1'b0;
				dot[22:1]<= data[21:0];
			end
			8'd129 : begin
				int[3]   <= 1'b0;
				int[2]   <= 1'b1;
				int[1:0] <= data[22:21];
				dot[1:0]	<= 2'b00;
				dot[22:2]<= data[20:0];
			end
			8'd130 : begin
				int[3]   <= 1'b1;
				int[2:0] <= data[22:20];
				dot[2:0]	<= 3'b000;
				dot[22:3]<= data[19:0];
			end
			default: begin
				int <= 4'd0;
				dot <= 3'b0;
			end
	endcase
end
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
begin
result[30:0] <= 31'd0;
end
else
	case(int_add)
	4'd0:begin
	if(dot_add[22]==1) begin
		result[30:23] <= 8'd126;
		result[22:0]	<= {dot_add[21:0],1'b0};
	end
	else if(dot_add[21]==1) begin
		result[30:23] <= 8'd125;
		result[22:0]	<= {dot_add[20:0],2'b00};
	end
	else if(dot_add[20]==1) begin
		result[30:23] <= 8'd124;
		result[22:0]	<= {dot_add[19:0],3'b000};
	end
	else if(dot_add[19]==1) begin
		result[30:23] <= 8'd123;
		result[22:0]	<= {dot_add[18:0],4'b0000};
	end
	else if(dot_add[18]==1) begin
		result[30:23] <= 8'd122;
		result[22:0]	<= {dot_add[17:0],5'd0};
	end
	else if(dot_add[17]==1) begin
		result[30:23] <= 8'd121;
		result[22:0]	<= {dot_add[16:0],6'd0000};
	end
	else if(dot_add[16]==1) begin
		result[30:23] <= 8'd120;
		result[22:0]	<= {dot_add[15:0],7'd0000};
	end
	else if(dot_add[15]==1) begin
		result[30:23] <= 8'd119;
		result[22:0]	<= {dot_add[14:0],8'd0000};
	end
	else if(dot_add[14]==1) begin
		result[30:23] <= 8'd118;
		result[22:0]	<= {dot_add[13:0],9'd0000};
	end
	else if(dot_add[13]==1) begin
		result[30:23] <= 8'd117;
		result[22:0]	<= {dot_add[12:0],10'd00000};
	end
	else if(dot_add[12]==1) begin
		result[30:23] <= 8'd116;
		result[22:0]	<= {dot_add[11:0],11'd0000};
	end
	else if(dot_add[11]==1) begin
		result[30:23] <= 8'd115;
		result[22:0]	<= {dot_add[10:0],12'd0000};
	end
	end
	4'd1:begin
		result[30:23] <= 8'd127;
		result[22:0]	<= dot_add[22:0];
	end
	4'd2:begin
		result[30:23] <= 8'd128;
		result[22]		<= 1'b0;
		result[21:0]	<= dot_add[22:1];
	end
	4'd3:begin
		result[30:23] <= 8'd128;
		result[22]		<= 1'b1;
		result[21:0]	<= dot_add[22:1];
	end	
	4'd4:begin
		result[30:23] <= 8'd129;
		result[22:21]	<= 2'b00;
		result[20:0]	<= dot_add[22:2];
	end
	4'd5:begin
		result[30:23] <= 8'd129;
		result[22:21]	<= 2'b01;
		result[20:0]	<= dot_add[22:2];
	end
	4'd6:begin
		result[30:23] <= 8'd129;
		result[22:21]	<= 2'b10;
		result[20:0]	<= dot_add[22:2];
	end
	4'd7:begin
		result[30:23] <= 8'd129;
		result[22:21]	<= 2'b11;
		result[20:0]	<= dot_add[22:2];
	end
	4'd8:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b000;
		result[19:0]	<= dot_add[22:3];
	end
	4'd9:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b001;
		result[19:0]	<= dot_add[22:3];
	end
	4'd10:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b010;
		result[19:0]	<= dot_add[22:3];
	end
	4'd11:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b011;
		result[19:0]	<= dot_add[22:3];
	end
	4'd12:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b100;
		result[19:0]	<= dot_add[22:3];
	end
	4'd13:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b101;
		result[19:0]	<= dot_add[22:3];
	end
	4'd14:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b110;
		result[19:0]	<= dot_add[22:3];
	end
	4'd15:begin
		result[30:23] <= 8'd130;
		result[22:20]	<= 3'b111;
		result[19:0]	<= dot_add[22:3];
	end
	default:;
	endcase
end

endmodule
