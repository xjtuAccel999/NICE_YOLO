`timescale 1ns / 1ps

module dma_vbuf#(

parameter  integer  FIFO_DEPTH   = 2048,
parameter  integer  W_ENABLE     = 1,
parameter  integer  R_ENABLE     = 1,

parameter  integer  AXI_ADDR_WIDTH = 32,
parameter  integer  AXI_DATA_WIDTH = 128,

parameter  [AXI_ADDR_WIDTH -1'b1: 0]          W_VBUF0ADDR  = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]          W_VBUF1ADDR  = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]          W_VBUF2ADDR  = 0,
parameter  integer  W_HSIZE      = 1920, 
parameter  integer  W_HSTRIDE    = 1920,
parameter  integer  W_VSIZE      = 1080,
parameter  integer  WH_DIV       = 2,
parameter  integer  W_BUFSIZE    = 3,

parameter  [AXI_ADDR_WIDTH -1'b1: 0]          R_VBUF0ADDR  = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]          R_VBUF1ADDR  = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]          R_VBUF2ADDR  = 0,
parameter  integer  R_HSIZE      = 1920, 
parameter  integer  R_HSTRIDE    = 1920,
parameter  integer  R_VSIZE      = 1080,
parameter  integer  RH_DIV       = 2,
parameter  integer  R_BUFSIZE    = 3
)
(
input  wire                     CLK,
input  wire                     RESETN,

input  wire                     vid_wclk, 
input  wire                     vid_wvs,
input  wire                     vid_wde,
input  wire [23: 0]             vid_wdata,
output wire [1 : 0]             vid_wsync_o,
input  wire [1 : 0]             vid_wbuf_i,

input  wire                     vid_rclk, 
input  wire                     vid_rvs,
input  wire                     vid_rde,
output wire [23: 0]             vid_rdata,
output wire [1 : 0]             vid_rsync_o,
input  wire [1 : 0]             vid_rbuf_i,
//----------dma signals write-------       
output wire [AXI_ADDR_WIDTH-1'b1: 0] dma_waddr,
output wire                     dma_wareq,
output wire [15: 0]             dma_wsize,                                     
input  wire                     dma_wbusy,		
output wire [AXI_DATA_WIDTH-1'b1:0]  dma_wdata,
input  wire                     dma_wvalid,
output wire                     dma_wready,
output wire                     dma_wirq,		
//----------dma signals read-------  
output wire [AXI_ADDR_WIDTH-1'b1: 0]  dma_raddr,
output wire                     dma_rareq,
output wire [15: 0]             dma_rsize,                                     
input  wire                     dma_rbusy,			
input  wire [AXI_DATA_WIDTH-1'b1:0]  dma_rdata,
input  wire                     dma_rvalid,
output wire                     dma_rready	,
output wire                     dma_rirq	
);

wire [3 :0]dma_wbuf;
wire [3 :0]dma_rbuf;

wire [3 :0] wbuf =  vid_wbuf_i;
wire [3 :0] rbuf =  vid_rbuf_i;

uivbuf # (
.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
.FIFO_DEPTH(FIFO_DEPTH),
.ENABLE_WRITE(W_ENABLE),
.WVBUF0_ADDR(W_VBUF0ADDR),
.WVBUF1_ADDR(W_VBUF1ADDR),
.WVBUF2_ADDR(W_VBUF2ADDR),
.WH_SIZE(W_HSIZE), 
.WH_STRIDE(W_HSTRIDE),
.WV_SIZE(W_VSIZE),
.WH_DIV(WH_DIV),
.WBUF_SIZE(W_BUFSIZE),

.ENABLE_READ(R_ENABLE),
.RVBUF0_ADDR(R_VBUF0ADDR),
.RVBUF1_ADDR(R_VBUF1ADDR),
.RVBUF2_ADDR(R_VBUF2ADDR),
.RH_SIZE(R_HSIZE),
.RH_STRIDE(R_HSTRIDE),
.RV_SIZE(R_VSIZE),
.RH_DIV(RH_DIV),
.RBUF_SIZE(R_BUFSIZE)
)uivbuf_u0
(
.ui_clk(CLK),
.ui_rstn(RESETN),
//Sensor video 
.W0_FS_i(vid_wvs),
.W0_wclk_i(vid_wclk),
.W0_wren_i(vid_wde),
.W0_data_i({8'hff,vid_wdata}), 
.W0_sync_cnt_o(vid_wsync_o),
.W0_buf_i(wbuf),
//vga/hdmi output -CH6_FIFO 
.R0_FS_i(vid_rvs),
.R0_rclk_i(vid_rclk),
.R0_rden_i(vid_rde),
.R0_data_o(vid_rdata),
.R0_sync_cnt_o(vid_rsync_o),
.R0_buf_i(rbuf),
       
.dma_waddr(dma_waddr)  ,
.dma_wareq(dma_wareq)  ,
.dma_wsize(dma_wsize)  ,                                     
.dma_wbusy(dma_wbusy)  ,			
.dma_wdata(dma_wdata)	 ,
.dma_wvalid(dma_wvalid),
.dma_wready(dma_wready),
.dma_raddr(dma_raddr)  ,
.dma_rareq(dma_rareq)  ,
.dma_rsize(dma_rsize)  ,                                     
.dma_rbusy(dma_rbusy)  ,			
.dma_rdata(dma_rdata)	 ,
.dma_rvalid(dma_rvalid),
.dma_rready(dma_rready),
.dma_wbuf  (dma_wbuf),	
.dma_wirq  (dma_wirq),		
.dma_rbuf  (dma_rbuf),	
.dma_rirq  (dma_rirq)
 ); 
  
    
endmodule
