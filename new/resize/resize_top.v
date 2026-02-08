
module resize_top(
    input i_clk,
    input i_rst_n,
    input start,
    input [23:0]          i_data,
    input                 i_de,

    output  wire [31:0]   dma_raddr,
    output                dma_rareq,
    input   wire          dma_rbusy,
    input   wire [63:0]   dma_rdata,
    output  wire [15:0]   dma_rsize,
    input   wire          dma_rvalid,
    output  wire          dma_rready,
    output  wire [31:0]   dma_waddr,
    output                dma_wareq,
    input   wire          dma_wbusy,
    output  wire [63:0]   dma_wdata,
    output  wire [15:0]   dma_wsize,
    input   wire          dma_wvalid,
    output  wire          dma_wready


    );

wire          o_de               ;
wire  [23:0]  o_data             ;
wire          full               ;
wire          wr_en              ;
wire [63:0]   out_data           ;
wire [8:0]    fifo_count         ;
wire          rd_en              ;
wire [63:0]   fifo_data          ;


resize u_resize(
    .i_clk    ( i_clk    ),
    .i_rst_n  ( i_rst_n  ),
    .start    ( start    ),
    .i_de     ( i_de     ),
    .i_data   ( i_data   ),
    .o_de     ( o_de     ),
    .o_data   ( o_data   )
);

fifo_control u_fifo_control(
    .clk     ( i_clk     ),
    .rst_n   ( i_rst_n   ),
    .in_de   ( o_de   ),
    .full    ( full    ),
    .wr_en   ( wr_en   ),
    .in_data ( o_data ),
    .out_data  ( out_data  )
);

fifo_generator_0 u_fifo_generator_0 (
  .clk              (i_clk     ),     // input wire clk
  .din              (out_data  ),     // input wire [63 : 0] din
  .wr_en            (wr_en     ),     // input wire wr_en
  .rd_en            (rd_en     ),     // input wire rd_en
  .dout             (fifo_data ),     // output wire [63 : 0] dout
  .full             (full      ),     // output wire full
  .empty            (          ),     // output wire empty
  .data_count       (fifo_count)      // output wire [8 : 0] data_count
);

dma_control u_dma_control(
    .fifo_count  ( fifo_count  ),
    .rd_en       ( rd_en       ),
    .fifo_data   ( fifo_data   ),
    .dma_raddr  ( dma_raddr  ),
    .dma_rareq  ( dma_rareq  ),
    .dma_rbusy  ( dma_rbusy  ),
    .dma_rdata  ( dma_rdata  ),
    .dma_rsize  ( dma_rsize  ),
    .dma_rvalid ( dma_rvalid ),
    .dma_rready ( dma_rready ),
    .dma_waddr  ( dma_waddr  ),
    .dma_wareq  ( dma_wareq  ),
    .dma_wbusy  ( dma_wbusy  ),
    .dma_wdata  ( dma_wdata  ),
    .dma_wsize  ( dma_wsize  ),
    .dma_wvalid ( dma_wvalid ),
    .dma_wready ( dma_wready ),
    .ui_clk      ( i_clk       ),
    .addr_ctl    ( start       ),
    .rst_n       ( i_rst_n     )
);



endmodule
