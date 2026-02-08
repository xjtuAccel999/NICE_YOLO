module dma_uart(
    input                 i_uart_rst_n,  //连接到按键
    input                 i_uart_rx,
    output                o_uart_tx,
    input                 clk_50M,

    output   reg [31:0]   dma_raddr,
    output   reg          dma_rareq,
    input                 dma_rbusy,
    input        [63:0]   dma_rdata,
    output       [15:0]   dma_rsize,
    input                 dma_rvalid,
    output                dma_rready
);

/********************串口读取数据******************/
parameter dma_READ_BURST_LEN = 16'd64;
parameter dma_READ_RAM_ADDR_BIT = 6;
parameter dma_READ_RAM_DATA_BIT = 64;


//串口接收地址
reg [31:0] uart_recv_addr;
wire [7:0] uart_recv_data;
reg [3:0] uart_rx_done_cnt;  //产生DMA读取标志
wire uart_rx_done;
always @(posedge clk_50M or negedge i_uart_rst_n) begin
    if(!i_uart_rst_n) begin
        uart_recv_addr <= 0;
        uart_rx_done_cnt <= 0;
    end
    else if(uart_rx_done) begin
        uart_recv_addr <= {uart_recv_addr[27:0],uart_recv_data[3:0]};  //按照顺序发送
        uart_rx_done_cnt <= uart_rx_done_cnt + 1;
    end
    else if(uart_rx_done_cnt == 4'd8)
        uart_rx_done_cnt <= 0;
end 

always @(posedge clk_50M or negedge i_uart_rst_n) begin
    if(!i_uart_rst_n) begin
        dma_rareq <= 0;
        dma_raddr <= 0;
    end
    else if(!dma_rbusy && uart_rx_done_cnt == 4'd8) begin
        dma_rareq <= 1;
        dma_raddr <= uart_recv_addr;
    end
    else if(dma_rareq && dma_rbusy)
        dma_rareq <= 0;
end

assign dma_rsize = dma_READ_BURST_LEN;
assign dma_rready = 1;

uart_rx_path uart_rx_path_u (
    .clk_i         (clk_50M         ), 
    .uart_rx_i     (i_uart_rx     ), 
    .uart_rx_data_o(uart_recv_data), 
    .uart_rx_done  (uart_rx_done  )
);

//dma读取数据到RAM
reg  [dma_READ_RAM_ADDR_BIT-1:0] addr_a;
reg  [dma_READ_RAM_ADDR_BIT-1:0] addr_b;
com_simple_dual_port_ram#(
    .WIDTH                 ( dma_READ_RAM_DATA_BIT  ),
    .ADDR_BIT              ( dma_READ_RAM_ADDR_BIT  ),
    .DEPTH                 ( dma_READ_BURST_LEN     ),
    .RAM_STYLE_VAL         ( "block" )
)u_com_simple_dual_port_ram(
    .clk        ( clk_50M        ),
    .we_a       ( dma_rvalid ),
    .en_a       ( 1'b1         ),
    .addr_a     ( addr_a       ),
    .di_a       ( dma_rdata ),
    .addr_b     ( addr_b       ),
    .dout_b     ( dout_b       )
);

//ram写地址自加，并产生ram读有效标志
reg [3:0] tx_cnt;
reg [63:0] dout_b_t;
wire [63:0] dout_b;
reg uart_tx_en;
wire uart_busy;
reg  uart_busy_t;
always @(posedge clk_50M or negedge i_uart_rst_n) begin
    if(!i_uart_rst_n) 
        addr_a <= 0;
    else if(dma_rvalid)
        addr_a = addr_a + 1;
end

reg uart_tx_valid;
always @(posedge clk_50M or negedge i_uart_rst_n) begin
    if(!i_uart_rst_n)
        uart_tx_valid <= 0;
    else if(addr_a == dma_READ_BURST_LEN - 1)
        uart_tx_valid <= 1;
    else if((addr_b == (dma_READ_BURST_LEN - 1)) && tx_cnt == 4'd7)
        uart_tx_valid <= 0;
end


//串口发送数据  dma数据位宽64位 串口数据位宽8位
always @(posedge clk_50M or negedge i_uart_rst_n) begin
    uart_busy_t <= uart_busy;
    if(!i_uart_rst_n || !uart_tx_valid) begin
        addr_b <= 0;
        tx_cnt <= 0;
        dout_b_t <= dout_b;
        uart_tx_en <= 0;
    end
    else if(tx_cnt == 4'd8) begin
        tx_cnt <= tx_cnt + 1;
    end
    else if(tx_cnt == 4'd9) begin
        dout_b_t <= dout_b;
        tx_cnt <= 0;
    end
    else if(uart_busy_t && ~uart_busy) begin   //下降沿
        if(tx_cnt == 4'd7) begin
            addr_b <= addr_b + 1;
            tx_cnt <= tx_cnt + 1;
        end
        else begin
            dout_b_t <= {8'd0,dout_b_t[63:8]};
            tx_cnt <= tx_cnt + 1;
        end
    end
    else if(!uart_busy) begin
        uart_tx_en <= 1;
        // dout_b_t <= dout_b;
    end
    else 
        uart_tx_en <= 0;
end



uart_tx_path u_uart_tx_path(
    .clk_i          ( clk_50M       ),
    .uart_tx_data_i ( dout_b_t[7:0] ),
    .uart_tx_en_i   ( uart_tx_en    ),
    .uart_tx_o      ( o_uart_tx     ),
    .uart_busy      ( uart_busy     )
);

endmodule