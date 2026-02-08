`timescale 1ns / 1ps

module dma_sd_uart(
    input           clk_50M       ,
    input           clk_50M_180   ,
    input           i_uart_rst_n  ,  //连接到按键
    input           i_uart_rx     ,
    output          o_uart_tx     ,
    input           dma_rst_n    ,
    output          sd_load_led   ,

    //SD卡接口
    input           sd_miso       ,  //SD卡SPI串行输入数据信号
    output          sd_clk        ,  //SD卡SPI时钟信号    
    output          sd_cs         ,  //SD卡SPI片选信号
    output          sd_mosi       ,  //SD卡SPI串行输出数据信号

    output [31:0]   dma_waddr    ,
    output          dma_wareq    ,
    input           dma_wbusy    ,
    output [63:0]   dma_wdata    ,
    output [15:0]   dma_wsize    ,
    input           dma_wvalid   ,
    output          dma_wready   ,
    output [31:0]   dma_raddr    ,
    output          dma_rareq    ,
    input           dma_rbusy    ,
    input  [63:0]   dma_rdata    ,
    output [15:0]   dma_rsize    ,
    input           dma_rvalid   ,
    output          dma_rready
);

dma_sd u_dma_sd(
    .clk_50M       ( clk_50M       ),
    .clk_50M_180   ( clk_50M_180   ),
    .dma_rst_n    ( dma_rst_n    ),
    .sd_load_led   ( sd_load_led   ),
    .sd_miso       ( sd_miso       ),
    .sd_clk        ( sd_clk        ),
    .sd_cs         ( sd_cs         ),
    .sd_mosi       ( sd_mosi       ),
    .dma_waddr    ( dma_waddr    ),
    .dma_wareq    ( dma_wareq    ),
    .dma_wbusy    ( dma_wbusy    ),
    .dma_wdata    ( dma_wdata    ),
    .dma_wsize    ( dma_wsize    ),
    .dma_wvalid   ( dma_wvalid   ),
    .dma_wready   ( dma_wready   )
);



dma_uart u_dma_uart(
    .i_uart_rst_n ( i_uart_rst_n ),
    .i_uart_rx    ( i_uart_rx    ),
    .o_uart_tx    ( o_uart_tx    ),
    .clk_50M      ( clk_50M      ),
    .dma_raddr   ( dma_raddr   ),
    .dma_rareq   ( dma_rareq   ),
    .dma_rbusy   ( dma_rbusy   ),
    .dma_rdata   ( dma_rdata   ),
    .dma_rsize   ( dma_rsize   ),
    .dma_rvalid  ( dma_rvalid  ),
    .dma_rready  ( dma_rready  )
);

endmodule