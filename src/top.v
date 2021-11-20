// top
module top(

	input				clk,
	input				rst_n,
	input		[8:0] sw,
	input				key,
	
	output	[6:0] seg

);

wire			bpnetwork_finish;
wire[9:0]	bpnetwork_result;

seg_display seg_display_u(
	.clk		(clk),
	.rst_n	(rst_n),
	.result	(bpnetwork_result),
	.en		(bpnetwork_finish),
	.seg		(seg)
);


bpnetwork bpnetwork_u(
	.clk		(clk),
	.rst_n	(rst_n),
	.sw		(sw),
	.en		(~key),
	.finish	(bpnetwork_finish),
	.result	(bpnetwork_result)
);


endmodule