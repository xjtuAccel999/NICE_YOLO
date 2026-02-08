module inferface_dma_master#(
	parameter ADDR_BIT=16
)(
	input 			clk,
	input 			rst_n,
	
	input 			send_enable,
	output 			send_done,

	input 	[31:0]	dma_addr,
	input   [15:0]	dma_len,
    
	//dma write port
	output [31:0]   dma_waddr,
	output reg  	dma_wareq,
	output [15:0]	dma_wsize,
	input  			dma_wbusy,
	output [63:0]   dma_wdata,
	input  			dma_wvalid,
	output       	dma_wready,

	input  [ADDR_BIT:0] addr_end,
	input  [ADDR_BIT:0] addr_start,
	
	output [ADDR_BIT:0] read_addr,
	input  [63:0] read_data
);

	// ila_0 u_ila(
	// 	.clk    (clk),
	// 	.probe0 ({dma_wdata}),
	// 	.probe1 ({dma_waddr,dma_wareq,dma_wsize,dma_wbusy,dma_wvalid,dma_wready,
	// 	          send_enable,dma_wbusy_t,send_done,send_enable_t0,send_enable_t1,send_enable_up,send_enable_flag}),
	// 	.probe2 ({addr_end,addr_start,read_addr,addr}),
	// 	.probe3 ({addr_cnt,addr_en})
	// );

	assign dma_wready = 1'b1;
	assign dma_wsize = dma_len;
	assign dma_waddr = dma_addr;

	reg [ADDR_BIT:0] addr;

	wire last;
	reg last_d;
	assign send_done     =last_d;
	assign last=(addr==(addr_end-addr_start-1));
	always@(posedge clk) begin
		last_d<=last;
	end
	
	reg send_enable_t0;
	reg send_enable_t1;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			send_enable_t0 <= 0;
			send_enable_t1 <= 0;
		end
		else begin
			send_enable_t0 <= send_enable;
			send_enable_t1 <= send_enable_t0;
		end
	end

	wire send_enable_up;
	assign send_enable_up = (~send_enable_t1) & send_enable_t0;
    reg send_enable_flag;
	always @(posedge clk) begin
		if(!rst_n ||dma_wareq)
			send_enable_flag <= 0;
		else if(send_enable_up)
			send_enable_flag <= 1;
	end


	assign dma_wdata  = read_data;
	assign read_addr   = addr+addr_start;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			dma_wareq <= 0;
		else if(send_enable_flag && (!dma_wbusy))
			dma_wareq <= 1;
		else if(dma_wareq & dma_wbusy)
			dma_wareq <= 0;
	end

	//采集dma_wbusy下降沿作为完成信号
	reg  dma_wbusy_t;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			dma_wbusy_t <= 0;
		else 
			dma_wbusy_t <= dma_wbusy;
	end

	// assign send_done = (!dma_wbusy) && dma_wbusy_t;


	reg [8:0]  addr_cnt;
	wire       addr_en;
	assign     addr_en = (addr_cnt > 9'd3) && (addr_cnt < 9'd260);
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			addr_cnt <= 0;
		else if(send_done)
			addr_cnt <= 0;
		else if(dma_wbusy) begin
			if(addr_cnt == 9'd264)
				addr_cnt <= 9'd4;
			else 
				addr_cnt <= addr_cnt + 1;
		end
	end

	always@(posedge clk) begin
		if(send_enable_flag) 
			addr<=0;
		else if(send_done)
			addr<=0;
		else begin
			// if(dma_wready && dma_wvalid && dma_wbusy) begin
			if(addr_en) 
				addr<=addr+1;
			else 
				addr<=addr;
		end
	end



endmodule