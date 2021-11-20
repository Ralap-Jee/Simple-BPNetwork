// seg_dispaly
module seg_display(

	input				clk,
	input				rst_n,
	input[9:0]		result,
	input				en,
	
//	output[3:0]		led
	output reg[6:0]		seg

);

reg		z;		// 0.0001
reg		v;		// 0.5000
reg		n;		// 0.9999
wire[2:0]led;

assign	led	=	{z, v, n};

always@(posedge clk or negedge rst_n)begin
if(!rst_n)
	seg <= 7'd0;
else
	case(led)
	3'b001: seg 	<= 7'b1001000;
	3'b010: seg 	<= 7'b1000001;
	3'b100: seg 	<= 7'b0100100;
	default : seg	<= 7'b0001001;
	endcase
end

always@(posedge clk or negedge rst_n)	begin
if(!rst_n)	begin
	z <= 1'b0;
	v <= 1'b0;
	n <= 1'b0;
end
else if(en)	begin
	if(result[9:2]<8'd125)	z <= 1'b1;							// <0.25  -- z
	else	begin
		case(result[9:2])
			8'd125 : begin												// 0.25~0.5
				if(result[1]==1'b1)	v <= 1'b1;					// 0.375~0.5 -- v
			end
			8'd126 : begin												// 0.5~1
				if(result[1:0]==2'b11) n <= 1'b1;				// 0.75~1 -- z
				else	v <= 1'b1;										// 0.5~0.625 -- v
			end
			default : begin
			z <= 1'b1;
			v <= 1'b1;
			n <= 1'b1;
			end
		endcase
	end
end
else	begin
	z <= z;
	v <= v;
	n <= n;
end
end


endmodule