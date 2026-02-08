`timescale 1ns / 1ps

module dma_sd(
    input           clk_50M       ,
    input           clk_50M_180   ,
    input           dma_rst_n    ,
    output          sd_load_led   ,

    //SD卡接口
    input           sd_miso       ,  //SD卡SPI串行输入数据信号
    output          sd_clk        ,  //SD卡SPI时钟信号    
    output          sd_cs         ,  //SD卡SPI片选信号
    output          sd_mosi       ,  //SD卡SPI串行输出数据信号

    output [31:0]   dma_waddr    ,
    output reg      dma_wareq    ,
    input           dma_wbusy    ,
    output [63:0]   dma_wdata    ,
    output [15:0]   dma_wsize    ,
    input           dma_wvalid   ,
    output          dma_wready   
);

//数据SD卡扇区地址
parameter sec_addr_fb0 = 32'd31616;
parameter sec_addr_fb1 = 32'd31680;
parameter sec_addr_fb2 = 32'd31744;
parameter sec_addr_fb3 = 32'd10432;
parameter sec_addr_fb4 = 32'd10496;
parameter sec_addr_fb5 = 32'd10560;
parameter sec_addr_fb6 = 32'd10624;
parameter sec_addr_fb7 = 32'd10688;
parameter sec_addr_fb8 = 32'd10752;
parameter sec_addr_fb9 = 32'd10816;

parameter sec_addr_fr0 = 32'd10880;
parameter sec_addr_fr1 = 32'd10944;
parameter sec_addr_fr2 = 32'd11008;
parameter sec_addr_fr3 = 32'd11072;
parameter sec_addr_fr4 = 32'd11136;
parameter sec_addr_fr5 = 32'd11200;
parameter sec_addr_fr6 = 32'd11264;
parameter sec_addr_fr7 = 32'd11328;
parameter sec_addr_fr8 = 32'd11392;
parameter sec_addr_fr9 = 32'd11456;

parameter sec_addr_fw0 = 32'd11520;
parameter sec_addr_fw1 = 32'd11584;
parameter sec_addr_fw2 = 32'd11648;
parameter sec_addr_fw3 = 32'd11712;
parameter sec_addr_fw4 = 32'd11904;
parameter sec_addr_fw5 = 32'd12480;
parameter sec_addr_fw6 = 32'd14784;
parameter sec_addr_fw7 = 32'd24000;
parameter sec_addr_fw8 = 32'd28608;
parameter sec_addr_fw9 = 32'd30912;

//数据SD卡扇区个数
parameter sec_len_fb0 = 32'd2;
parameter sec_len_fb1 = 32'd2;
parameter sec_len_fb2 = 32'd2;
parameter sec_len_fb3 = 32'd2;
parameter sec_len_fb4 = 32'd4;
parameter sec_len_fb5 = 32'd8;
parameter sec_len_fb6 = 32'd16;
parameter sec_len_fb7 = 32'd4;
parameter sec_len_fb8 = 32'd8;
parameter sec_len_fb9 = 32'd2;

parameter sec_len_fr0 = 32'd4;
parameter sec_len_fr1 = 32'd4;
parameter sec_len_fr2 = 32'd4;
parameter sec_len_fr3 = 32'd4;
parameter sec_len_fr4 = 32'd4;
parameter sec_len_fr5 = 32'd4;
parameter sec_len_fr6 = 32'd4;
parameter sec_len_fr7 = 32'd4;
parameter sec_len_fr8 = 32'd4;
parameter sec_len_fr9 = 32'd4;

parameter sec_len_fw0 = 32'd4;
parameter sec_len_fw1 = 32'd10;
parameter sec_len_fw2 = 32'd36;
parameter sec_len_fw3 = 32'd144;
parameter sec_len_fw4 = 32'd576;
parameter sec_len_fw5 = 32'd2304;
parameter sec_len_fw6 = 32'd9216;
parameter sec_len_fw7 = 32'd4608;
parameter sec_len_fw8 = 32'd2304;
parameter sec_len_fw9 = 32'd648;

//DDR地址
parameter ddr_addr_fb0 = 32'h4000_0000;
parameter ddr_addr_fb1 = 32'h4100_0000;
parameter ddr_addr_fb2 = 32'h4200_0000;
parameter ddr_addr_fb3 = 32'h4300_0000;
parameter ddr_addr_fb4 = 32'h4400_0000;
parameter ddr_addr_fb5 = 32'h4500_0000;
parameter ddr_addr_fb6 = 32'h4600_0000;
parameter ddr_addr_fb7 = 32'h4700_0000;
parameter ddr_addr_fb8 = 32'h4800_0000;
parameter ddr_addr_fb9 = 32'h4900_0000;

parameter ddr_addr_fr0 = 32'h5000_0000;
parameter ddr_addr_fr1 = 32'h5100_0000;
parameter ddr_addr_fr2 = 32'h5200_0000;
parameter ddr_addr_fr3 = 32'h5300_0000;
parameter ddr_addr_fr4 = 32'h5400_0000;
parameter ddr_addr_fr5 = 32'h5500_0000;
parameter ddr_addr_fr6 = 32'h5600_0000;
parameter ddr_addr_fr7 = 32'h5700_0000;
parameter ddr_addr_fr8 = 32'h5800_0000;
parameter ddr_addr_fr9 = 32'h5900_0000;

parameter ddr_addr_fw0 = 32'h6000_0000;
parameter ddr_addr_fw1 = 32'h6100_0000;
parameter ddr_addr_fw2 = 32'h6200_0000;
parameter ddr_addr_fw3 = 32'h6300_0000;
parameter ddr_addr_fw4 = 32'h6400_0000;
parameter ddr_addr_fw5 = 32'h6500_0000;
parameter ddr_addr_fw6 = 32'h6600_0000;
parameter ddr_addr_fw7 = 32'h6700_0000;
parameter ddr_addr_fw8 = 32'h6800_0000;
parameter ddr_addr_fw9 = 32'h6900_0000;

//test图片数据
parameter sec_addr_image_bus     = 32'd33600;
parameter sec_addr_image_bird    = 32'd35328;
parameter sec_addr_image_person  = 32'd37056;
parameter sec_addr_image_oranges = 32'd38784;
parameter sec_addr_image_cow     = 32'd10432;
parameter sec_len_image_bus      = 32'd1686;
parameter sec_len_image_bird     = 32'd1686;
parameter sec_len_image_person   = 32'd1686;
parameter sec_len_image_oranges  = 32'd1686;
parameter sec_len_image_cow      = 32'd1686;
parameter ddr_addr_image_bus     = 32'h7000_0000;
parameter ddr_addr_image_bird    = 32'h7100_0000;
parameter ddr_addr_image_person  = 32'h7200_0000;
parameter ddr_addr_image_oranges = 32'h7300_0000;
parameter ddr_addr_image_cow     = 32'h7400_0000;





parameter file_num = 6'd35;

wire     i_rst_n;
assign   i_rst_n = sd_init_done;
assign   sd_load_led = sd_read_finish;
assign   dma_wready = 1;
assign   dma_wsize = 16'd64;
assign   dma_waddr = ddr_addr;
assign   dma_wdata = (addr_b == 6'd1)? ram_data_addr_eq0:dma_wdata_t;

reg            rd_start_en   ;  //开始读SD卡数据信号
reg   [31:0]   rd_sec_addr   ;  //读数据扇区地址
wire           rd_busy       ;  //读数据忙信号
wire           rd_val_en     ;  //读数据有效信号
wire  [15:0]   rd_val_data   ;  //读数据 

reg  [5:0]  file_sel;
reg  [31:0] sec_addr_t;
reg  [31:0] sec_len_t;
reg  [31:0] ddr_addr_t;
//文件地址选择
always @(*) begin
    case(file_sel)
        6'd0: begin
            sec_addr_t   <= sec_addr_fb0;
            sec_len_t    <= sec_len_fb0 ;
            ddr_addr_t   <= ddr_addr_fb0;
        end
        6'd1: begin
            sec_addr_t   <= sec_addr_fb1;
            sec_len_t    <= sec_len_fb1 ;
            ddr_addr_t   <= ddr_addr_fb1;
        end
        6'd2: begin
            sec_addr_t   <= sec_addr_fb2;
            sec_len_t    <= sec_len_fb2 ;
            ddr_addr_t   <= ddr_addr_fb2;
        end
        6'd3: begin
            sec_addr_t   <= sec_addr_fb3;
            sec_len_t    <= sec_len_fb3 ;
            ddr_addr_t   <= ddr_addr_fb3;
        end
        6'd4: begin
            sec_addr_t   <= sec_addr_fb4;
            sec_len_t    <= sec_len_fb4 ;
            ddr_addr_t   <= ddr_addr_fb4;
        end
        6'd5: begin
            sec_addr_t   <= sec_addr_fb5;
            sec_len_t    <= sec_len_fb5 ;
            ddr_addr_t   <= ddr_addr_fb5;
        end
        6'd6: begin
            sec_addr_t   <= sec_addr_fb6;
            sec_len_t    <= sec_len_fb6 ;
            ddr_addr_t   <= ddr_addr_fb6;
        end
        6'd7: begin
            sec_addr_t   <= sec_addr_fb7;
            sec_len_t    <= sec_len_fb7 ;
            ddr_addr_t   <= ddr_addr_fb7;
        end
        6'd8: begin
            sec_addr_t   <= sec_addr_fb8;
            sec_len_t    <= sec_len_fb8 ;
            ddr_addr_t   <= ddr_addr_fb8;
        end
        6'd9: begin
            sec_addr_t   <= sec_addr_fb9;
            sec_len_t    <= sec_len_fb9 ;
            ddr_addr_t   <= ddr_addr_fb9;
        end
        6'd10: begin
            sec_addr_t   <= sec_addr_fr0;
            sec_len_t    <= sec_len_fr0 ;
            ddr_addr_t   <= ddr_addr_fr0;
        end
        6'd11: begin
            sec_addr_t   <= sec_addr_fr1;
            sec_len_t    <= sec_len_fr1 ;
            ddr_addr_t   <= ddr_addr_fr1;
        end
        6'd12: begin
            sec_addr_t   <= sec_addr_fr2;
            sec_len_t    <= sec_len_fr2 ;
            ddr_addr_t   <= ddr_addr_fr2;
        end
        6'd13: begin
            sec_addr_t   <= sec_addr_fr3;
            sec_len_t    <= sec_len_fr3 ;
            ddr_addr_t   <= ddr_addr_fr3;
        end
        6'd14: begin
            sec_addr_t   <= sec_addr_fr4;
            sec_len_t    <= sec_len_fr4 ;
            ddr_addr_t   <= ddr_addr_fr4;
        end
        6'd15: begin
            sec_addr_t   <= sec_addr_fr5;
            sec_len_t    <= sec_len_fr5 ;
            ddr_addr_t   <= ddr_addr_fr5;
        end
        6'd16: begin
            sec_addr_t   <= sec_addr_fr6;
            sec_len_t    <= sec_len_fr6 ;
            ddr_addr_t   <= ddr_addr_fr6;
        end
        6'd17: begin
            sec_addr_t   <= sec_addr_fr7;
            sec_len_t    <= sec_len_fr7 ;
            ddr_addr_t   <= ddr_addr_fr7;
        end
        6'd18: begin
            sec_addr_t   <= sec_addr_fr8;
            sec_len_t    <= sec_len_fr8 ;
            ddr_addr_t   <= ddr_addr_fr8;
        end
        6'd19: begin
            sec_addr_t   <= sec_addr_fr9;
            sec_len_t    <= sec_len_fr9 ;
            ddr_addr_t   <= ddr_addr_fr9;
        end
        6'd20: begin
            sec_addr_t   <= sec_addr_fw0;
            sec_len_t    <= sec_len_fw0 ;
            ddr_addr_t   <= ddr_addr_fw0;
        end
        6'd21: begin
            sec_addr_t   <= sec_addr_fw1;
            sec_len_t    <= sec_len_fw1 ;
            ddr_addr_t   <= ddr_addr_fw1;
        end
        6'd22: begin
            sec_addr_t   <= sec_addr_fw2;
            sec_len_t    <= sec_len_fw2 ;
            ddr_addr_t   <= ddr_addr_fw2;
        end
        6'd23: begin
            sec_addr_t   <= sec_addr_fw3;
            sec_len_t    <= sec_len_fw3 ;
            ddr_addr_t   <= ddr_addr_fw3;
        end
        6'd24: begin
            sec_addr_t   <= sec_addr_fw4;
            sec_len_t    <= sec_len_fw4 ;
            ddr_addr_t   <= ddr_addr_fw4;
        end
        6'd25: begin
            sec_addr_t   <= sec_addr_fw5;
            sec_len_t    <= sec_len_fw5 ;
            ddr_addr_t   <= ddr_addr_fw5;
        end
        6'd26: begin
            sec_addr_t   <= sec_addr_fw6;
            sec_len_t    <= sec_len_fw6 ;
            ddr_addr_t   <= ddr_addr_fw6;
        end
        6'd27: begin
            sec_addr_t   <= sec_addr_fw7;
            sec_len_t    <= sec_len_fw7 ;
            ddr_addr_t   <= ddr_addr_fw7;
        end
        6'd28: begin
            sec_addr_t   <= sec_addr_fw8;
            sec_len_t    <= sec_len_fw8 ;
            ddr_addr_t   <= ddr_addr_fw8;
        end
        6'd29: begin
            sec_addr_t   <= sec_addr_fw9;
            sec_len_t    <= sec_len_fw9 ;
            ddr_addr_t   <= ddr_addr_fw9;
        end
        6'd30: begin
            sec_addr_t   <= sec_addr_image_bus;
            sec_len_t    <= sec_len_image_bus ;
            ddr_addr_t   <= ddr_addr_image_bus;
        end
        6'd31: begin
            sec_addr_t   <= sec_addr_image_bird;
            sec_len_t    <= sec_len_image_bird ;
            ddr_addr_t   <= ddr_addr_image_bird;
        end
        6'd32: begin
            sec_addr_t   <= sec_addr_image_person;
            sec_len_t    <= sec_len_image_person ;
            ddr_addr_t   <= ddr_addr_image_person;
        end
        6'd33: begin
            sec_addr_t   <= sec_addr_image_oranges;
            sec_len_t    <= sec_len_image_oranges ;
            ddr_addr_t   <= ddr_addr_image_oranges;
        end
        6'd34: begin
            sec_addr_t   <= sec_addr_image_cow;
            sec_len_t    <= sec_len_image_cow ;
            ddr_addr_t   <= ddr_addr_image_cow;
        end
        default: begin
            sec_addr_t   <= sec_addr_fb0;
            sec_len_t    <= sec_len_fb0 ;
            ddr_addr_t   <= ddr_addr_fb0;
        end
    endcase
end

//计算地址
reg   [31:0] sec_addr_offset;
wire  [31:0] sec_addr;
assign       sec_addr = sec_addr_offset + sec_addr_t;
reg   [31:0] ddr_addr;
always @(posedge clk_50M or negedge i_rst_n) begin
    if(!i_rst_n || sd_read_finish) begin
        sec_addr_offset <= 0;
        file_sel <= 0;
        addr_a_clr <= 0;
        ddr_addr <= ddr_addr_t;
    end
    else if (addr_a_clr) begin
        ddr_addr <= ddr_addr_t;
        addr_a_clr <= 0;
    end
    else if(addr_a == 6'd63 && cat_data_valid) begin
        if(sec_addr_offset == sec_len_t - 1) begin
            sec_addr_offset <= 0;
            addr_a_clr <= 1;
            // ddr_addr <= ddr_addr_t;
            if(file_sel == file_num - 1) begin
                file_sel <= 0;
                sd_read_finish <= 1;
            end
            else
                file_sel <= file_sel + 1;
        end
        else begin
            sec_addr_offset <= sec_addr_offset + 1;
            ddr_addr <= ddr_addr + 32'd512;
        end
    end
    else
        addr_a_clr <= 0;
end

//读数据开始使能
reg  sd_read_finish;
always @(posedge clk_50M or negedge i_rst_n) begin
    if(!i_rst_n || sd_read_finish)
        rd_start_en <= 0;
    else if(!rd_busy && !sd_read_finish && !ram_rw_flag) 
        rd_start_en <= 1;
    else 
        rd_start_en <= 0;
end

//SD卡数据拼接   16->64
reg [63:0] cat_data;
reg [1:0]  cat_cnt;
reg        cat_data_valid;
always @(posedge clk_50M or negedge i_rst_n) begin
    if(!i_rst_n || sd_read_finish) begin
        cat_data <= 0;
        cat_cnt <= 0;
        cat_data_valid <= 0;
    end
    else if(rd_val_en) begin
        cat_cnt <= cat_cnt + 1;
        // cat_data <= {cat_data[47:0],rd_val_data};
        cat_data <= {rd_val_data[7:0],rd_val_data[15:8],cat_data[63:16]};
        if(cat_cnt == 2'd3) 
            cat_data_valid <= 1;
        else 
            cat_data_valid <= 0;     
    end
    else begin
       cat_data_valid <= 0; 
    end
end

//写RAM地址生成
reg  [5:0] addr_a;
reg        addr_a_clr;
always @(posedge clk_50M) begin
    if(addr_a_clr || sd_read_finish)
        addr_a <= 0;
    else if(cat_data_valid)
        addr_a <= addr_a + 1;
end

//缓存RAM
wire [63:0] dma_wdata_t;
com_simple_dual_port_ram#(
    .WIDTH         ( 64      ),
    .ADDR_BIT      ( 6       ),
    .DEPTH         ( 64      ),
    .RAM_STYLE_VAL ( "block" )
)u_com_simple_dual_port_ram(
    .clk        ( clk_50M              ),
    .we_a       ( cat_data_valid       ),
    .en_a       ( 1'b1                 ),
    .addr_a     ( addr_a               ),
    .di_a       ( cat_data             ),
    .addr_b     ( addr_b               ),
    .dout_b     ( dma_wdata_t         )
);

//读RAM到DDR标志位
reg     ram_rw_flag;
always @(posedge clk_50M) begin
    if(sd_read_finish)
        ram_rw_flag <= 0;
    else if(addr_a == 6'd63) 
        ram_rw_flag <= 1;
    else if(addr_b == 6'd63)
        ram_rw_flag <= 0;
end

//控制fdma写数据
reg [5:0] addr_b;
reg dma_wareq_t;
reg [63:0] ram_data_addr_eq0;
always @(posedge clk_50M or negedge i_rst_n) begin
    dma_wareq_t <= dma_wareq;
    if(!i_rst_n || !ram_rw_flag || sd_read_finish)
        addr_b <= 0;
    // else if(ram_rw_flag && dma_wvalid)
    else if(dma_wareq_t && !dma_wareq && ram_rw_flag) begin
        ram_data_addr_eq0 <= dma_wdata_t;
        addr_b <= addr_b + 1;
    end
    else if(ram_rw_flag && dma_wvalid)
        addr_b <= addr_b + 1;
end

//产生fdma写请求信号
always @(posedge clk_50M or negedge i_rst_n) begin
    if(!i_rst_n || sd_read_finish) 
        dma_wareq <= 0;
    else if(!dma_wbusy && !sd_read_finish && ram_rw_flag) 
        dma_wareq <= 1;
    else if(dma_wbusy && dma_wareq)
        dma_wareq <= 0;
end

sd_ctrl_top u_sd_ctrl_top(
    .clk_ref        ( clk_50M             ),
    .clk_ref_180deg ( clk_50M_180         ),
    .rst_n          ( dma_rst_n          ),
    .sd_miso        ( sd_miso             ),
    .sd_clk         ( sd_clk              ),
    .sd_cs          ( sd_cs               ),
    .sd_mosi        ( sd_mosi             ),
    .wr_start_en    (                     ),
    .wr_sec_addr    (                     ),
    .wr_data        (                     ),
    .wr_busy        (                     ),
    .wr_req         (                     ),
    .rd_start_en    ( rd_start_en         ),
    .rd_sec_addr    ( sec_addr            ),
    .rd_busy        ( rd_busy             ),
    .rd_val_en      ( rd_val_en           ),
    .rd_val_data    ( rd_val_data         ),
    .sd_init_done   ( sd_init_done        )
);

endmodule