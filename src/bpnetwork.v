// bpnetwork
module bpnetwork(

	input				clk,
	input				rst_n,
	input		[8:0] sw,
	input				en,
	
	output			finish,
	output	[9:0]result

);

// state code			 
parameter Sidle=3'b000,		//IDLE
			 S0=3'b001,			//launch lay1_mod 
			 S1=3'b010,			//waite
			 S2=3'b011,			//launch lay2_mod 
			 S3=3'b100;			//waite

reg[2:0]		state;
reg[1:0]		next_state;
wire[5:0]	bpparams_addra;
wire[5:0]	bpparams_addrb;
wire[31:0]	bpparams_dataa;
wire[31:0]	bpparams_datab;
wire			lay1_en;
wire			lay1_val;
wire[8:0]	lay1_x;
wire[31:0]	lay1_y	[0:3];
wire			lay2_en;
wire			lay2_val;
wire[31:0]	lay2_y;
wire[31:0]	lay1_result	[0:3];
reg			en_delay;
reg			lay1_val_delay;
wire			en_posedge;
wire			lay1_val_posedge;

//assign	lay1_result[0] = (lay1_val==1'b1)? lay1_y[0] : lay1_result[0];
//assign	lay1_result[1] = (lay1_val==1'b1)? lay1_y[1] : lay1_result[1];
//assign	lay1_result[2] = (lay1_val==1'b1)? lay1_y[2] : lay1_result[2];
//assign	lay1_result[3] = (lay1_val==1'b1)? lay1_y[3] : lay1_result[3];
assign	result			= (lay2_val==1'b1)? lay2_y[30:21]		: result;
assign	finish			= lay2_val;
assign	en_posedge		=	(en==1'b1 && en_delay==1'b0)? 1'b1 : 1'b0;
assign	lay1_val_posedge=	(lay1_val==1'b1 && lay1_val_delay==1'b0)? 1'b1:1'b0;
assign	lay1_en			=	en_posedge;
//assign	lay1_en			=	en;
assign	lay2_en			=	lay1_val_posedge;
assign	lay1_x			=	( en_posedge )?	sw			:	lay1_x;

always@(posedge clk)
begin
en_delay <= en;
lay1_val_delay <= lay1_val;
end


lay1_mod lay1_mod_u(
	.clk				(clk),
	.rst_n			(rst_n),
	.en				(lay1_en),
	.x					(lay1_x),
	.valid			(lay1_val),
	.y0				(lay1_y[0]),
	.y1				(lay1_y[1]),
	.y2				(lay1_y[2]),
	.y3				(lay1_y[3]),
	.rom_data		(bpparams_dataa),
	.rom_addr		(bpparams_addra)
);

lay2_mod lay2_mod_u(
	.clk				(clk),
	.rst_n			(rst_n),
	.en				(lay2_en),
	.x0				(lay1_y[0]),
	.x1				(lay1_y[1]),
	.x2				(lay1_y[2]),
	.x3				(lay1_y[3]),
	.valid			(lay2_val),
	.y					(lay2_y),
	.rom_data		(bpparams_datab),
	.rom_addr		(bpparams_addrb)
);


bpparams bpparams_u(
	.clock			(clk),
	.address_a		(bpparams_addra),
	.address_b		(bpparams_addrb),
	.q_a				(bpparams_dataa),
	.q_b				(bpparams_datab)
);


endmodule