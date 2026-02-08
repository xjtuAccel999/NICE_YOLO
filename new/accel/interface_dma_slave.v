module interface_dma_slave#(
	parameter ADDR_BIT=16
)(
	input 			clk,
	input 			rst_n,
	
	input			recv_enable,
	output 			recv_done,

	input 	[31:0]	dma_addr,
	input   [15:0]	dma_len,
	
	//dma read port
	output	[31:0]	dma_raddr,
	output	reg		dma_rareq,
	output	[15:0]	dma_rsize,
	input 			dma_rbusy,
	input	[63:0]  dma_rdata,
	input 			dma_rvalid,
	output			dma_rready,
	
	output reg	 [ADDR_BIT:0] 	write_addr,
	output		 [63:0] 	write_data,
	output 					write_enable
);

// ila_1 u_ila_1(
// 	.clk        (clk),
// 	.probe0     ({dma_rdata}),
// 	.probe1     ({dma_raddr,dma_rareq,dma_rsize,dma_rbusy,dma_rvalid}),
// 	.probe2     ({dma_rbusy_downedge,clr,recv_enable_up,recv_enable_flag,recv_enable,recv_done,write_enable,write_addr})
// );

assign dma_raddr = dma_addr;
assign dma_rsize = dma_len;
assign dma_rready = 1'b1;

reg  dma_rbusy_t0;
reg  dma_rbusy_t1;
wire dma_rbusy_downedge;
always@(posedge clk) begin
	dma_rbusy_t0 <= dma_rbusy;
	dma_rbusy_t1 <= dma_rbusy_t0;
end
assign dma_rbusy_downedge = dma_rbusy_t1 & (~dma_rbusy_t0);

wire clr;

assign recv_done     =  dma_rbusy_downedge;
assign clr           = (!rst_n)||recv_done;

reg recv_enable_t0;
reg recv_enable_t1;
always @(posedge clk) begin
	if(clr) begin
		recv_enable_t0 <= 0;
		recv_enable_t1 <= 0;
	end
	else begin
		recv_enable_t0 <= recv_enable;
		recv_enable_t1 <= recv_enable_t0;
	end
end

wire recv_enable_up;
assign recv_enable_up = (~recv_enable_t1) & recv_enable_t0;
reg recv_enable_flag;
always @(posedge clk) begin
	if(clr ||dma_rareq)
		recv_enable_flag <= 0;
	else if(recv_enable_up)
		recv_enable_flag <= 1;
end


always @(posedge clk) begin
	if(clr)
		dma_rareq <= 0;
	else if (recv_enable_flag && (!dma_rbusy))
		dma_rareq <= 1;
	else if(dma_rareq && dma_rbusy)
		dma_rareq <= 0;
end

assign write_enable  =dma_rbusy&&dma_rvalid;
assign write_data    =dma_rdata;

always@(posedge clk) begin
	if(clr) begin
		write_addr<=0;
	end else begin
		if(write_enable) begin
			write_addr<=write_addr+1;
		end else begin
			write_addr<=write_addr;
		end
	end
end
	
endmodule