`timescale 1ns / 1ps

module uivbuf#(
parameter  integer                   FIFO_DEPTH     = 2048,
parameter  integer                   AXI_DATA_WIDTH = 128,
parameter  integer                   AXI_ADDR_WIDTH = 32,
parameter  integer                   ENABLE_WRITE   = 1,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]  WVBUF0_ADDR    = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]  WVBUF1_ADDR    = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]  WVBUF2_ADDR    = 0,
parameter  integer                   WH_SIZE        = 1920, 
parameter  integer                   WH_STRIDE      = 1920,
parameter  integer                   WV_SIZE        = 1080,
parameter  integer                   WH_DIV         = 2,
parameter  integer                   WBUF_SIZE      = 3,

parameter  integer                   ENABLE_READ    = 1,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]  RVBUF0_ADDR    = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]  RVBUF1_ADDR    = 0,
parameter  [AXI_ADDR_WIDTH -1'b1: 0]  RVBUF2_ADDR    = 0,
parameter  integer                   RH_SIZE        = 1920, 
parameter  integer                   RH_STRIDE      = 1920,
parameter  integer                   RV_SIZE        = 1080,
parameter  integer                   RH_DIV         = 2,
parameter  integer                   RBUF_SIZE      = 3

)
(
input                               ui_clk,
input                               ui_rstn,
//sensor input -W0_FIFO--------------
input                               W0_FS_i,
input                               W0_wclk_i,
input                               W0_wren_i,
input      [31 : 0]                 W0_data_i, 
output     [1   :0]                 W0_sync_cnt_o,
input      [1   :0]                 W0_buf_i,
//----------dma signals write-------       
output     [AXI_ADDR_WIDTH-1'b1: 0] dma_waddr,
output                              dma_wareq,
output     [15  :0]                 dma_wsize,                                     
input                               dma_wbusy,		
output     [AXI_DATA_WIDTH-1'b1:0]  dma_wdata,
input                               dma_wvalid,
output                              dma_wready,
output     [4   :0]                 dma_wbuf,
output                              dma_wirq,		
//----------dma signals read-------  
input                               R0_FS_i,
input                               R0_rclk_i,
input                               R0_rden_i,
output     [31  :0]                 R0_data_o,
output     [1   :0]                 R0_sync_cnt_o,
input      [1   :0]                 R0_buf_i,

output     [AXI_ADDR_WIDTH-1'b1: 0] dma_raddr,
output                              dma_rareq,
output     [15: 0]                  dma_rsize,                                     
input                               dma_rbusy,			
input      [AXI_DATA_WIDTH-1'b1:0]  dma_rdata,
input                               dma_rvalid,
output                              dma_rready,
output     [4  :0]                  dma_rbuf,
output                              dma_rirq	
);    

reg                                 dma_wareq= 1'b0;
reg                                 dma_rareq= 1'b0;

function integer clog2;
  input integer value;
  begin 
    value = value-1;
    for (clog2=0; value>0; clog2=clog2+1)
      value = value>>1;
    end 
  endfunction

localparam WFIFO_DEPTH = FIFO_DEPTH;
localparam W0_WR_DATA_COUNT_WIDTH = clog2(WFIFO_DEPTH)+1;
localparam W0_RD_DATA_COUNT_WIDTH = clog2(WFIFO_DEPTH/4)+1;

localparam WVBUF_SIZE           = (WBUF_SIZE - 1'b1);
localparam WV_BURST_TIMES       = (WV_SIZE*WH_DIV);
localparam dma_WH_BURST        = (WH_SIZE*32/AXI_DATA_WIDTH)/WH_DIV;
localparam WH_BURST_ADDR_INC    = (WH_SIZE*4)/WH_DIV;
localparam WH_LAST_ADDR_INC     = (WH_STRIDE-WH_SIZE)*4 + WH_BURST_ADDR_INC;

localparam S_IDLE  =  2'd0;  
localparam S_RST   =  2'd1;  
localparam S_DATA1 =  2'd2;   
localparam S_DATA2 =  2'd3; 

reg                                     W0_FIFO_Rst=0; 
wire                                    W0_FS;
reg [5 :0]                              W0_Fbuf=0;
reg [1 :0]                              W_MS=0; 
reg [AXI_ADDR_WIDTH-1'b1:0]             W0_addr=0; 
reg [7 :0]                              W0_fcnt=0;
reg [15:0]                              W0_bcnt=0; 
wire[W0_RD_DATA_COUNT_WIDTH-1'b1 :0]    W0_rcnt;
reg                                     W0_REQ=0; 
reg [3 :0]                              irq_dly_cnt =0;
reg [AXI_ADDR_WIDTH-1'b1:0]             dma_waddr_base=0;
reg [3 :0]                              wdiv_cnt =0;
reg [4 :0]                              W0_Fbuf_sync;

assign dma_wbuf  = W0_Fbuf_sync;
assign dma_wsize = dma_WH_BURST;
assign dma_wirq = (irq_dly_cnt>0);

assign dma_waddr = dma_waddr_base + W0_addr;
always @(*) begin
case(W0_Fbuf_sync[1:0])
    0:dma_waddr_base = WVBUF0_ADDR;
    1:dma_waddr_base = WVBUF1_ADDR;
    2:dma_waddr_base = WVBUF2_ADDR;
    default :
      dma_waddr_base = WVBUF0_ADDR;
endcase
end

generate  if(ENABLE_WRITE == 1)begin : dma_WRITE
always @(posedge ui_clk) begin
    if(ui_rstn == 1'b0)begin
        irq_dly_cnt <= 4'd0;
    end
    else if(W0_bcnt == WV_BURST_TIMES - 1'b1)
        irq_dly_cnt <= 15;
     else if(irq_dly_cnt >0)
        irq_dly_cnt <= irq_dly_cnt - 1'b1;
end

fs_cap fs_cap_W0(
 .clk_i(ui_clk),
 .rstn_i(ui_rstn),
 .vs_i(W0_FS_i),
 .fs_cap_o(W0_FS)
);

assign dma_wready = 1'b1;
assign W0_sync_cnt_o = W0_Fbuf[1:0];
//assign pkg_wr_data = W0_fcnt;
 always @(posedge ui_clk) begin
    if(!ui_rstn)begin
        W_MS <= S_IDLE;
        W0_addr <= 0;
        dma_wareq <= 1'd0;
        W0_FIFO_Rst <= 1'b1;
        W0_fcnt <= 0;
        W0_bcnt <= 0;
        W0_Fbuf <= 7'd0;
        W0_Fbuf_sync <= 6'd0;
        wdiv_cnt <=0;
    end
    else begin
      case(W_MS)
        S_IDLE:begin
          W0_addr <= 0;
          W0_bcnt <= 11'd0;
          W0_fcnt <= 0;
          wdiv_cnt <=0;
          if(W0_FS) begin
            W_MS <= S_RST;
            if(W0_Fbuf < WVBUF_SIZE)
                W0_Fbuf <= W0_Fbuf + 1'b1; 
            else 
                W0_Fbuf <= 7'd0;  
          end
       end
        S_RST:begin
            W0_Fbuf_sync[1:0] <= W0_buf_i;
          if(W0_fcnt > 8'd40 ) W_MS <= S_DATA1;
             W0_FIFO_Rst <= (W0_fcnt < 8'd20); 
             W0_fcnt <= W0_fcnt +1'd1;
        end          
        S_DATA1:begin 
          if(dma_wbusy == 1'b0 && W0_REQ )begin
             dma_wareq  <= 1'b1; 
          end 
          else if(dma_wbusy == 1'b1) begin
             dma_wareq  <= 1'b0;
             W_MS    <= S_DATA2;
          end          
         end
        S_DATA2:begin 
            if(dma_wbusy == 1'b0)begin
                if(W0_bcnt == WV_BURST_TIMES - 1'b1)
                    W_MS <= S_IDLE;
                else begin
                    if(wdiv_cnt < WH_DIV - 1'b1)begin
                        W0_addr <= W0_addr +  WH_BURST_ADDR_INC;  
                        wdiv_cnt <= wdiv_cnt + 1'b1;
                     end
                    else begin
                        W0_addr <= W0_addr + WH_LAST_ADDR_INC;
                        wdiv_cnt <= 0;
                    end
                    W0_bcnt <= W0_bcnt + 1'b1;
                    W_MS    <= S_DATA1;
                end 
            end
         end
       endcase
    end
 end 


wire W0_rbusy;
always@(posedge ui_clk)     
     W0_REQ  <= (W0_rcnt > dma_WH_BURST - 2)&&(~W0_rbusy); 

xpm_fifo_async # (
  .FIFO_MEMORY_TYPE          ("auto"),           //string; "auto", "block", or "distributed";
  .ECC_MODE                  ("no_ecc"),         //string; "no_ecc" or "en_ecc";
  .RELATED_CLOCKS            (0),                //positive integer; 0 or 1
  .FIFO_WRITE_DEPTH          (WFIFO_DEPTH),     //positive integer
  .WRITE_DATA_WIDTH          (AXI_DATA_WIDTH/4),               //positive integer
  .WR_DATA_COUNT_WIDTH       (W0_WR_DATA_COUNT_WIDTH),               //positive integer
  .PROG_FULL_THRESH          (100),               //positive integer
  .FULL_RESET_VALUE          (0),                //positive integer; 0 or 1
  .USE_ADV_FEATURES          ("0707"),           //string; "0000" to "1F1F"; 
  .READ_MODE                 ("fwft"),            //string; "std" or "fwft";
  .FIFO_READ_LATENCY         (0),                //positive integer;
  .READ_DATA_WIDTH           (AXI_DATA_WIDTH),               //positive integer
  .RD_DATA_COUNT_WIDTH       (W0_RD_DATA_COUNT_WIDTH),               //positive integer
  .PROG_EMPTY_THRESH         (10),               //positive integer
  .DOUT_RESET_VALUE          ("0"),              //string
  .CDC_SYNC_STAGES           (2),                //positive integer
  .WAKEUP_TIME               (0)                 //positive integer; 0 or 2;
) xpm_fifo_W0_inst (
      .rst              (W0_FIFO_Rst),
      .wr_clk           (W0_wclk_i),
      .wr_en            (W0_wren_i),
      .din              (W0_data_i),
      .full             (),
      .overflow         (),
      .prog_full        (),
      .wr_data_count    (),
      .almost_full      (),
      .wr_ack           (),
      .wr_rst_busy      (),
      .rd_clk           (ui_clk),
      .rd_en            (dma_wvalid),
      .dout             (dma_wdata),
      .empty            (),
      .underflow        (),
      .rd_rst_busy      (W0_rbusy),
      .prog_empty       (),
      .rd_data_count    (W0_rcnt),
      .almost_empty     (),
      .data_valid       (W0_dvalid),
      .sleep            (1'b0),
      .injectsbiterr    (1'b0),
      .injectdbiterr    (1'b0),
      .sbiterr          (),
      .dbiterr          ()

);
end
endgenerate

localparam RVBUF_SIZE           = (RBUF_SIZE - 1'b1);
localparam RV_BURST_TIMES       = (RV_SIZE*RH_DIV);
localparam dma_RH_BURST        = (RH_SIZE*32/AXI_DATA_WIDTH)/RH_DIV;
localparam RH_BURST_ADDR_INC    = (RH_SIZE*4)/RH_DIV;
localparam RH_LAST_ADDR_INC   = (RH_STRIDE-RH_SIZE)*4 + RH_BURST_ADDR_INC;

localparam RFIFO_DEPTH = FIFO_DEPTH/4;
localparam R0_WR_DATA_COUNT_WIDTH = clog2(FIFO_DEPTH/4)+1;
localparam R0_RD_DATA_COUNT_WIDTH = clog2(FIFO_DEPTH)+1;

wire  R0_FS;  
reg   R0_FIFO_Rst =0;
reg [6 :0] R0_Fbuf =0;
reg [3 :0] rirq_dly_cnt =0;
reg [1 :0] R_MS =0;
reg [AXI_ADDR_WIDTH-1'b1:0] R0_addr =0;
reg [7 :0] R0_fcnt =0;
reg [15:0] R0_bcnt =0;
wire[R0_WR_DATA_COUNT_WIDTH-1'b1 :0] R0_wcnt;
reg R0_REQ = 0;
reg [3:0]rdiv_cnt =0;
reg [AXI_ADDR_WIDTH-1'b1:0] dma_raddr_base=0; 
reg [4:0]R0_Fbuf_sync;

assign dma_rsize = dma_RH_BURST;
assign dma_rirq = (rirq_dly_cnt>0);
assign dma_rbuf  = R0_Fbuf_sync;

assign dma_raddr = dma_raddr_base + R0_addr;
always @(*) begin
case(R0_Fbuf_sync[1:0])
    0:dma_raddr_base = RVBUF0_ADDR;
    1:dma_raddr_base = RVBUF1_ADDR;
    2:dma_raddr_base = RVBUF2_ADDR;
    default :
      dma_raddr_base = RVBUF2_ADDR;
endcase
end

generate  if(ENABLE_READ == 1)begin : dma_READ

always @(posedge ui_clk) begin
    if(ui_rstn == 1'b0)begin
        rirq_dly_cnt <= 4'd0;
    end
    else if(R0_bcnt == RV_BURST_TIMES - 1'b1)
        rirq_dly_cnt <= 15;
     else if(rirq_dly_cnt >0)
        rirq_dly_cnt <= rirq_dly_cnt - 1'b1;
end

fs_cap fs_cap_R0(
  .clk_i(ui_clk),
  .rstn_i(ui_rstn),
  .vs_i(R0_FS_i),
  .fs_cap_o(R0_FS)
);
assign R0_sync_cnt_o = R0_Fbuf[1:0];
assign dma_rready = 1'b1;

 always @(posedge ui_clk) begin
   if(!ui_rstn)begin
       R_MS <= S_IDLE;
       R0_addr <= 0;
       dma_rareq <= 1'd0;
       R0_fcnt <=0;
       R0_bcnt <=0;
       R0_FIFO_Rst <= 1'b1;
       R0_Fbuf <= 7'd0; 
       rdiv_cnt <=0;    
       R0_Fbuf_sync <= 0;  
   end
   else begin
     case(R_MS)
       S_IDLE:begin
         R0_addr <= 0;
         R0_fcnt <=0;
         R0_bcnt <=0;
         rdiv_cnt <=0;
         if(R0_FS) begin
            R_MS <= S_RST;
            if(R0_Fbuf < RVBUF_SIZE)
                R0_Fbuf <= R0_Fbuf + 1'b1;
            else 
                R0_Fbuf <= 0; 
         end
       end 
       S_RST:begin
          R0_Fbuf_sync[1:0] <= R0_buf_i;
         if(R0_fcnt > 8'd40 ) R_MS <= S_DATA1;
            R0_FIFO_Rst <= (R0_fcnt < 8'd20); 
            R0_fcnt <= R0_fcnt + 1'd1;
       end  
       S_DATA1:begin 
         if(dma_rbusy == 1'b0 && R0_REQ)begin
            dma_rareq  <= 1'b1;  
         end
         else if(dma_rbusy == 1'b1) begin
            dma_rareq  <= 1'b0;
            R_MS    <= S_DATA2;
         end         
        end
        S_DATA2:begin 
            if(dma_rbusy == 1'b0)begin
                if(R0_bcnt == RV_BURST_TIMES - 1'b1)
                    R_MS <= S_IDLE;
                else begin
                    if(rdiv_cnt < RH_DIV - 1'b1)begin
                        R0_addr <= R0_addr +  RH_BURST_ADDR_INC;  
                        rdiv_cnt <= rdiv_cnt + 1'b1;
                     end
                    else begin
                        R0_addr <= R0_addr + RH_LAST_ADDR_INC;
                        rdiv_cnt <= 0;
                    end
                    R0_bcnt <= R0_bcnt + 1'b1;
                    R_MS    <= S_DATA1;
                end 
            end
         end
      endcase
   end
end 

wire R0_wbusy;
always@(posedge ui_clk)      
     R0_REQ  <= (R0_wcnt < dma_RH_BURST - 2)&&(~R0_wbusy);

xpm_fifo_async # (
  .FIFO_MEMORY_TYPE          ("auto"),           //string; "auto", "block", or "distributed";
  .ECC_MODE                  ("no_ecc"),         //string; "no_ecc" or "en_ecc";
  .RELATED_CLOCKS            (0),                //positive integer; 0 or 1
  .FIFO_WRITE_DEPTH          (RFIFO_DEPTH),     //positive integer
  .WRITE_DATA_WIDTH          (AXI_DATA_WIDTH),               //positive integer
  .WR_DATA_COUNT_WIDTH       (R0_WR_DATA_COUNT_WIDTH),               //positive integer
  .PROG_FULL_THRESH          (20),               //positive integer
  .FULL_RESET_VALUE          (0),                //positive integer; 0 or 1
  .USE_ADV_FEATURES          ("0707"),           //string; "0000" to "1F1F"; 
  .READ_MODE                 ("fwft"),            //string; "std" or "fwft";
  .FIFO_READ_LATENCY         (0),                //positive integer;
  .READ_DATA_WIDTH           (AXI_DATA_WIDTH/4),               //positive integer
  .RD_DATA_COUNT_WIDTH       (R0_RD_DATA_COUNT_WIDTH),               //positive integer
  .PROG_EMPTY_THRESH         (10),               //positive integer
  .DOUT_RESET_VALUE          ("0"),              //string
  .CDC_SYNC_STAGES           (2),                //positive integer
  .WAKEUP_TIME               (0)                 //positive integer; 0 or 2;
) xpm_fifo_R0_inst (
      .rst              (R0_FIFO_Rst),
      .wr_clk           (ui_clk),
      .wr_en            (dma_rvalid),
      .din              (dma_rdata),
      .full             (),
      .overflow         (),
      .prog_full        (),
      .wr_data_count    (R0_wcnt),
      .almost_full      (),
      .wr_ack           (),
      .wr_rst_busy      (R0_wbusy),
      .rd_clk           (R0_rclk_i),
      .rd_en            (R0_rden_i),
      .dout             (R0_data_o),
      .empty            (),
      .underflow        (),
      .rd_rst_busy      (),
      .prog_empty       (),
      .rd_data_count    (),
      .almost_empty     (),
      .data_valid       (),
      .sleep            (1'b0),
      .injectsbiterr    (1'b0),
      .injectdbiterr    (1'b0),
      .sbiterr          (),
      .dbiterr          ()

);
end
endgenerate

endmodule

