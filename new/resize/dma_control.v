
module dma_control(
input   wire [8:0]    fifo_count,
output  wire          rd_en,
input   wire [63:0]   fifo_data,
output  wire [31:0]   dma_raddr,
output  reg           dma_rareq,
input   wire          dma_rbusy,
input   wire [63:0]   dma_rdata,
output  wire [15:0]   dma_rsize,
input   wire          dma_rvalid,
output  wire          dma_rready,
output  wire [31:0]   dma_waddr,
output  reg           dma_wareq,
input   wire          dma_wbusy,
output  wire [63:0]   dma_wdata,
output  wire [15:0]   dma_wsize,
input   wire          dma_wvalid,
output  wire          dma_wready,
input   wire          ui_clk,
input   wire          addr_ctl,
input   wire          rst_n
    );

assign dma_rready = 0;
assign dma_wready = 1;
parameter dma_BURST_LEN  = 16'd418;
parameter ADDR_BASE0 = 32'h3500_0000; 
parameter ADDR_BASE1 = 32'h3600_0000; 
parameter ADDR_INC = dma_BURST_LEN * 8;//写一次产生的地址偏移
 
parameter WRITE1 = 0;
parameter WRITE2 = 1;
parameter WAIT   = 2;


reg [31: 0] dma_waddr_r;
reg [2  :0] T_S = 0;
reg [8 :0]  tran_cnt;
// reg addr_ctl;

assign dma_waddr = addr_ctl ? (dma_waddr_r + ADDR_BASE1) : (dma_waddr_r + ADDR_BASE0);
// assign dma_raddr = dma_waddr - ADDR_INC;

assign dma_wsize = dma_BURST_LEN;
// assign dma_rsize = dma_BURST_LEN;


assign dma_wdata = fifo_data;
assign rd_en = dma_wvalid;


always @(posedge ui_clk or negedge rst_n)begin
    if(!rst_n)begin
        T_S <=0;   
        dma_wareq  <= 1'b0; 
        dma_rareq  <= 1'b0; 
        dma_waddr_r <=0; 
        tran_cnt <= 9'd0;  
        // addr_ctl <= 1'b1;    
    end 
    else begin
        case(T_S)      
        WRITE1:begin
            if((fifo_count > 9'd417) && !dma_wbusy)begin
                dma_wareq  <= 1'b1; 
            end
            if(dma_wareq&&dma_wbusy)begin
                dma_wareq  <= 1'b0; 
                T_S         <= WRITE2;
            end
        end
        WRITE2:begin
            if(!dma_wbusy) begin
                T_S <= WAIT;
                if(tran_cnt == 257) begin
                    tran_cnt <= 0;
                    // addr_ctl <= ~addr_ctl;
                    dma_waddr_r  <= 0;
                end
                else begin
                    tran_cnt <= tran_cnt + 1;
                    dma_waddr_r  <= dma_waddr_r + ADDR_INC;
                end
            end 
        end
        WAIT:begin
            T_S <= WRITE1;
        end 
        default:
            T_S <= WRITE1;     
        endcase
    end
  end
  
endmodule
