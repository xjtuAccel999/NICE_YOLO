
`timescale 1ns / 1ns

module dma#
(
parameter  integer        M_AXI_ID_WIDTH		    = 1				,
parameter  integer        M_AXI_ID			        = 0				,
parameter  integer        M_AXI_ADDR_WIDTH			= 32			,
parameter  integer        M_AXI_DATA_WIDTH			= 128					
)
(
input   wire [M_AXI_ADDR_WIDTH-1 : 0]       dma_waddr          ,
input                                       dma_wareq          ,
input   wire [15 : 0]                       dma_wsize          ,                                     
output                                      dma_wbusy          ,
				
input   wire [M_AXI_DATA_WIDTH-1 :0]        dma_wdata			,
output  wire                                dma_wvalid         ,
input	wire                                dma_wready			,

input   wire [M_AXI_ADDR_WIDTH-1 : 0]       dma_raddr          ,
input                                       dma_rareq          ,
input   wire [15 : 0]                       dma_rsize          ,                                     
output                                      dma_rbusy          ,
				
output  wire [M_AXI_DATA_WIDTH-1 :0]        dma_rdata			,
output  wire                                dma_rvalid         ,
input	wire                                dma_rready			,
		
input 	wire  								M_AXI_ACLK			,
input 	wire  								M_AXI_ARESETN		,
output 	wire [M_AXI_ID_WIDTH-1 : 0]		    M_AXI_AWID			,
output 	wire [M_AXI_ADDR_WIDTH-1 : 0] 	    M_AXI_AWADDR		,
output 	wire [7 : 0]						M_AXI_AWLEN			,
output 	wire [2 : 0] 						M_AXI_AWSIZE		,
output 	wire [1 : 0] 						M_AXI_AWBURST		,
output 	wire  								M_AXI_AWLOCK		,
output 	wire [3 : 0] 						M_AXI_AWCACHE		,
output 	wire [2 : 0] 						M_AXI_AWPROT		,
output 	wire [3 : 0] 						M_AXI_AWQOS			,
output 	wire  								M_AXI_AWVALID		,
input	wire  								M_AXI_AWREADY		,
output  wire [M_AXI_ID_WIDTH-1 : 0] 		M_AXI_WID			,
output  wire [M_AXI_DATA_WIDTH-1 : 0] 	    M_AXI_WDATA			,
output  wire [M_AXI_DATA_WIDTH/8-1 : 0] 	M_AXI_WSTRB			,
output  wire  								M_AXI_WLAST			,
output  wire  								M_AXI_WVALID		,
input   wire  								M_AXI_WREADY		,
input   wire [M_AXI_ID_WIDTH-1 : 0] 		M_AXI_BID			,
input   wire [1 : 0] 						M_AXI_BRESP			,
input   wire  								M_AXI_BVALID		,
output  wire  								M_AXI_BREADY		,
output  wire [M_AXI_ID_WIDTH-1 : 0] 		M_AXI_ARID			,

output  wire [M_AXI_ADDR_WIDTH-1 : 0] 	    M_AXI_ARADDR		,	 	
output  wire [7 : 0] 						M_AXI_ARLEN			,	 
output  wire [2 : 0] 						M_AXI_ARSIZE		,	 
output  wire [1 : 0] 						M_AXI_ARBURST		,	 
output  wire  								M_AXI_ARLOCK		,	 
output  wire [3 : 0] 						M_AXI_ARCACHE		,	 
output  wire [2 : 0] 						M_AXI_ARPROT		,	 
output  wire [3 : 0] 						M_AXI_ARQOS			,	 	   
output  wire  								M_AXI_ARVALID		,	 
input   wire  								M_AXI_ARREADY		,	 
input   wire [M_AXI_ID_WIDTH-1 : 0] 		M_AXI_RID			,	 
input   wire [M_AXI_DATA_WIDTH-1 : 0] 	    M_AXI_RDATA			,	 
input   wire [1 : 0] 						M_AXI_RRESP			,	 
input   wire  								M_AXI_RLAST			,	 
input   wire  								M_AXI_RVALID		,    
output  wire  								M_AXI_RREADY			
		
	);

localparam AXI_BYTES =  M_AXI_DATA_WIDTH/8;


function integer clogb2 (input integer bit_depth);              
begin                                                           
	 for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	 bit_depth = bit_depth >> 1;                                 
end    

endfunction                                                     
//dma axi write----------------------------------------------
reg 	[M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr	=0;
reg  						 		axi_awvalid	= 1'b0;
wire 	[M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata	;
wire								axi_wlast	;
reg  								axi_wvalid	= 1'b0;
wire                               w_next      = (M_AXI_WVALID & M_AXI_WREADY);
reg   [8 :0]                       wburst_len  = 1  ; 
reg   [8 :0]                       wburst_cnt  = 0  ; 
reg   [15:0]                       wdma_cnt   = 0  ;
reg                                axi_wstart_locked  =0;  
wire  [15:0] axi_wburst_size   =   wburst_len * AXI_BYTES;	

assign M_AXI_AWID		= M_AXI_ID;
assign M_AXI_AWADDR		= axi_awaddr;
assign M_AXI_AWLEN		= wburst_len - 1;
assign M_AXI_AWSIZE		= clogb2(AXI_BYTES-1);
assign M_AXI_AWBURST	= 2'b01;
assign M_AXI_AWLOCK		= 1'b0;
assign M_AXI_AWCACHE	= 4'b0010;
assign M_AXI_AWPROT		= 3'h0;
assign M_AXI_AWQOS		= 4'h0;
assign M_AXI_AWVALID	= axi_awvalid;
assign M_AXI_WDATA		= axi_wdata;
assign M_AXI_WSTRB		= {(AXI_BYTES){1'b1}};
assign M_AXI_WLAST		= axi_wlast;
assign M_AXI_WVALID		= axi_wvalid & dma_wready;
assign M_AXI_BREADY		= 1'b1;


//----------------------------------------------------------------------------	
//AXI4 FULL Write
assign  axi_wdata        = dma_wdata;
assign  dma_wvalid      = w_next;
reg     dma_wstart_locked = 1'b0;
wire    dma_wend;
wire    dma_wstart;
assign   dma_wbusy = dma_wstart_locked ;

always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0 || dma_wend == 1'b1 )
		dma_wstart_locked <= 1'b0;
	else if(dma_wstart)
		dma_wstart_locked <= 1'b1; 		                       
		
assign dma_wstart = (dma_wstart_locked == 1'b0 && dma_wareq == 1'b1);


//AXI4 write burst lenth busrt addr ------------------------------
always @(posedge M_AXI_ACLK)
    if(dma_wstart)    
        axi_awaddr <= dma_waddr;
    else if(axi_wlast == 1'b1)
        axi_awaddr <= axi_awaddr + axi_wburst_size ;  


//AXI4 write cycle -----------------------------------------------
reg axi_wstart_locked_r1 = 1'b0, axi_wstart_locked_r2 = 1'b0;
always @(posedge M_AXI_ACLK)begin
    axi_wstart_locked_r1 <= axi_wstart_locked;
    axi_wstart_locked_r2 <= axi_wstart_locked_r1;
end
always @(posedge M_AXI_ACLK)
	if((dma_wstart_locked == 1'b1) &&  axi_wstart_locked == 1'b0)
	    axi_wstart_locked <= 1'b1; 
	else if(axi_wlast == 1'b1 || dma_wstart == 1'b1)
	    axi_wstart_locked <= 1'b0;
	    
//AXI4 addr valid and write addr-----------------------------------	
always @(posedge M_AXI_ACLK)
     if((axi_wstart_locked_r1 == 1'b1) &&  axi_wstart_locked_r2 == 1'b0)
         axi_awvalid <= 1'b1;
     else if((axi_wstart_locked == 1'b1 && M_AXI_AWREADY == 1'b1)|| axi_wstart_locked == 1'b0)
         axi_awvalid <= 1'b0; 		


//AXI4 write data---------------------------------------------------		
always @(posedge M_AXI_ACLK)
	if((axi_wstart_locked_r1 == 1'b1) &&  axi_wstart_locked_r2 == 1'b0)
		axi_wvalid <= 1'b1;
	else if(axi_wlast == 1'b1 || axi_wstart_locked == 1'b0)
		axi_wvalid <= 1'b0;


//AXI4 write data burst len counter----------------------------------
always @(posedge M_AXI_ACLK)
	if(axi_wstart_locked == 1'b0)
		wburst_cnt <= 'd0;
	else if(w_next)
		wburst_cnt <= wburst_cnt + 1'b1;    
		   	
assign axi_wlast = (w_next == 1'b1) && (wburst_cnt == M_AXI_AWLEN);


//dma write data burst len counter----------------------------------
reg wburst_len_req = 1'b0;
reg [15:0] dma_wleft_cnt =16'd0;

always @(posedge M_AXI_ACLK)
        wburst_len_req <= dma_wstart|axi_wlast;
         
always @(posedge M_AXI_ACLK)
	if( dma_wstart )begin
		wdma_cnt <= 1'd0;
		dma_wleft_cnt <= dma_wsize;
	end
	else if(w_next)begin
		wdma_cnt <= wdma_cnt + 1'b1;	
	    dma_wleft_cnt <= (dma_wsize - 1'b1) - wdma_cnt;
    end

assign  dma_wend = w_next && (dma_wleft_cnt == 1 );

always @(posedge M_AXI_ACLK)begin
     if(wburst_len_req)begin
        if(dma_wleft_cnt[15:8] >0)  wburst_len <= 256;
        else 
            wburst_len <= dma_wleft_cnt[7:0];
     end
     else wburst_len <= wburst_len;
end

//dma axi read----------------------------------------------
reg 	[M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr =0	;
reg  						 		axi_arvalid	 =1'b0;
wire								axi_rlast	;
reg  								axi_rready	= 1'b0;
wire                               r_next      = (M_AXI_RVALID && M_AXI_RREADY);
reg   [8 :0]                       rburst_len  = 1  ; 
reg   [8 :0]                       rburst_cnt  = 0  ; 
reg   [15:0]                       rdma_cnt   = 0  ;
reg                                axi_rstart_locked =0; 
wire  [15:0] axi_rburst_size   =   rburst_len * AXI_BYTES;	

assign M_AXI_ARID		= M_AXI_ID;
assign M_AXI_ARADDR		= axi_araddr;
assign M_AXI_ARLEN		= rburst_len - 1;
assign M_AXI_ARSIZE		= clogb2((AXI_BYTES)-1);
assign M_AXI_ARBURST	= 2'b01;
assign M_AXI_ARLOCK		= 1'b0;
assign M_AXI_ARCACHE	= 4'b0010;
assign M_AXI_ARPROT		= 3'h0;
assign M_AXI_ARQOS		= 4'h0;
assign M_AXI_ARVALID	= axi_arvalid;
assign M_AXI_RREADY		= axi_rready&&dma_rready;
assign dma_rdata       = M_AXI_RDATA;    
assign dma_rvalid      = r_next;    

//AXI4 FULL Read----------------------------------------- 	

reg     dma_rstart_locked = 1'b0;
wire    dma_rend;
wire    dma_rstart;
assign   dma_rbusy = dma_rstart_locked ;

always @(posedge M_AXI_ACLK)
	if(M_AXI_ARESETN == 1'b0 || dma_rend == 1'b1)
		dma_rstart_locked <= 1'b0;
	else if(dma_rstart)
		dma_rstart_locked <= 1'b1; 		                       

assign dma_rstart = (dma_rstart_locked == 1'b0 && dma_rareq == 1'b1);


//AXI4 read burst lenth busrt addr ------------------------------
always @(posedge M_AXI_ACLK)
    if(dma_rstart == 1'b1)    
        axi_araddr <= dma_raddr;
    else if(axi_rlast == 1'b1)
        axi_araddr <= axi_araddr + axi_rburst_size ;     


//AXI4 r_cycle_flag------------------------------------- 	
reg axi_rstart_locked_r1 = 1'b0, axi_rstart_locked_r2 = 1'b0;
always @(posedge M_AXI_ACLK)begin
    axi_rstart_locked_r1 <= axi_rstart_locked;
    axi_rstart_locked_r2 <= axi_rstart_locked_r1;
end
always @(posedge M_AXI_ACLK)
	if((dma_rstart_locked == 1'b1) &&  axi_rstart_locked == 1'b0)
	    axi_rstart_locked <= 1'b1; 
	else if(axi_rlast == 1'b1 || dma_rstart == 1'b1)
	    axi_rstart_locked <= 1'b0;
	    
//AXI4 addr valid and read addr-----------------------------------	
always @(posedge M_AXI_ACLK)
     if((axi_rstart_locked_r1 == 1'b1) &&  axi_rstart_locked_r2 == 1'b0)
         axi_arvalid <= 1'b1;
     else if((axi_rstart_locked == 1'b1 && M_AXI_ARREADY == 1'b1)|| axi_rstart_locked == 1'b0)
         axi_arvalid <= 1'b0; 		


//AXI4 read data---------------------------------------------------		
always @(posedge M_AXI_ACLK)
	if((axi_rstart_locked_r1 == 1'b1) &&  axi_rstart_locked_r2 == 1'b0)
		axi_rready <= 1'b1;
	else if(axi_rlast == 1'b1 || axi_rstart_locked == 1'b0)
		axi_rready <= 1'b0;//	
		
//AXI4 read data burst len counter----------------------------------
always @(posedge M_AXI_ACLK)
	if(axi_rstart_locked == 1'b0)
		rburst_cnt <= 'd0;
	else if(r_next)
		rburst_cnt <= rburst_cnt + 1'b1;       		
assign axi_rlast = (r_next == 1'b1) && (rburst_cnt == M_AXI_ARLEN);


//dma read data burst len counter----------------------------------
reg rburst_len_req = 1'b0;
reg [15:0] dma_rleft_cnt =16'd0;
  
always @(posedge M_AXI_ACLK)
	    rburst_len_req <= dma_rstart | axi_rlast;  
        
always @(posedge M_AXI_ACLK)
	if(dma_rstart )begin
		rdma_cnt <= 1'd0;
	    dma_rleft_cnt <= dma_rsize;
	end
	else if(r_next)begin
		rdma_cnt <= rdma_cnt + 1'b1;	
		dma_rleft_cnt <= (dma_rsize - 1'b1) - rdma_cnt;
    end

assign  dma_rend = r_next && (dma_rleft_cnt == 1 );


//axi auto burst len caculate-----------------------------------------

always @(posedge M_AXI_ACLK)begin
     if(rburst_len_req)begin
        if(dma_rleft_cnt[15:8] >0)  
            rburst_len <= 256;
        else 
            rburst_len <= dma_rleft_cnt[7:0];
     end
     else rburst_len <= rburst_len;
end
		
		              		   
endmodule


