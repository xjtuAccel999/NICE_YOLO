module yolov3_tiny_ctrl (
    input       clk,
    input       rst,
    input       ap_done,
    output        yolo_en,
    output         resize_load,
    input        yolo_layer_finish,
    input        yolo_clr,
    output     [31:0] reg0,
    output     [31:0] reg1,
    output     [31:0] reg2,
    output     [31:0] reg3,
    output     [31:0] reg4,
    output     [31:0] reg5,
    output     [31:0] reg6,
    output     [31:0] reg7
);
`include "ctrl_para.v"

// ila_0 u_ila(
//     .clk           (clk),
//     .probe0        ({ap_done,conv_layer_cnt,conv_layer_finish,yolo_clr_up,yolo_en,resize_load,yolo_layer_finish,yolo_clr,yolo_layer_finish_up}),
//     .probe1        ({reg0,reg1})
// );

//计数器 
// reg [31:0] delay_cnt;
// always @(posedge clk) begin
//     if(rst) 
//         delay_cnt <= 0;
//     else if(conv_layer_cnt == 9 && conv_layer_finish == 1) 
//         delay_cnt <= 0;
//     else 
//         delay_cnt <= delay_cnt + 1;
// end

//采集yolo_layer_finsh上升沿
reg yolo_layer_finish_t0;
reg yolo_layer_finish_t1;
always @(posedge clk) begin
    if(rst) begin
        yolo_layer_finish_t0 <= 0;
        yolo_layer_finish_t1 <= 0;
    end
    else begin
        yolo_layer_finish_t0 <= yolo_layer_finish;
        yolo_layer_finish_t1 <= yolo_layer_finish_t0;
    end
end

wire yolo_layer_finish_up;
assign yolo_layer_finish_up = ~yolo_layer_finish_t1 & yolo_layer_finish_t0;

//采集yolo_clr上升沿
reg yolo_clr_t0;
reg yolo_clr_t1;
always @(posedge clk) begin
    if(rst) begin
        yolo_clr_t0 <= 0;
        yolo_clr_t1 <= 0;
    end
    else begin
        yolo_clr_t0 <= yolo_clr;
        yolo_clr_t1 <= yolo_clr_t0;
    end
end

wire yolo_clr_up;
assign yolo_clr_up = ~yolo_clr_t1 & yolo_clr_t0;


reg yolo_en_t0;
reg yolo_en_t1;
reg yolo_en_t;
always @(posedge clk) begin
    if(rst) begin
        yolo_en_t0 <= 0;
        yolo_en_t1 <= 0;
    end
    else begin
        yolo_en_t0 <= yolo_en_t;
        yolo_en_t1 <= yolo_en_t0;
    end
end
assign yolo_en = yolo_en_t1;

reg [31:0] reg0_t1;
reg [31:0] reg1_t1;
reg [31:0] reg2_t1;
reg [31:0] reg3_t1;
reg [31:0] reg4_t1;
reg [31:0] reg5_t1;
reg [31:0] reg6_t1;
reg [31:0] reg7_t1;
reg [31:0] reg0_t0;
reg [31:0] reg1_t0;
reg [31:0] reg2_t0;
reg [31:0] reg3_t0;
reg [31:0] reg4_t0;
reg [31:0] reg5_t0;
reg [31:0] reg6_t0;
reg [31:0] reg7_t0;
reg [31:0] reg0_t;
reg [31:0] reg1_t;
reg [31:0] reg2_t;
reg [31:0] reg3_t;
reg [31:0] reg4_t;
reg [31:0] reg5_t;
reg [31:0] reg6_t;
reg [31:0] reg7_t;
always @(posedge clk) begin
    if(rst) begin
        reg0_t1 <= 0;
        reg1_t1 <= 0;
        reg2_t1 <= 0;
        reg3_t1 <= 0;
        reg4_t1 <= 0;
        reg5_t1 <= 0;
        reg6_t1 <= 0;
        reg7_t1 <= 0;
        reg0_t0 <= 0;
        reg1_t0 <= 0;
        reg2_t0 <= 0;
        reg3_t0 <= 0;
        reg4_t0 <= 0;
        reg5_t0 <= 0;
        reg6_t0 <= 0;
        reg7_t0 <= 0;
    end
    else begin
        reg0_t1 <= reg0_t0;
        reg1_t1 <= reg1_t0;
        reg2_t1 <= reg2_t0;
        reg3_t1 <= reg3_t0;
        reg4_t1 <= reg4_t0;
        reg5_t1 <= reg5_t0;
        reg6_t1 <= reg6_t0;
        reg7_t1 <= reg7_t0;
        reg0_t0 <= reg0_t;
        reg1_t0 <= reg1_t;
        reg2_t0 <= reg2_t;
        reg3_t0 <= reg3_t;
        reg4_t0 <= reg4_t;
        reg5_t0 <= reg5_t;
        reg6_t0 <= reg6_t;
        reg7_t0 <= reg7_t;
    end
end

assign reg0 = reg0_t1;
assign reg1 = reg1_t1;
assign reg2 = reg2_t1;
assign reg3 = reg3_t1;
assign reg4 = reg4_t1;
assign reg5 = reg5_t1;
assign reg6 = reg6_t1;
assign reg7 = reg7_t1;


reg [3:0]  conv_layer_cnt;
reg        conv_layer_finish;

//每次卷积池化的控制信号
always @(posedge clk) begin
    if(rst) 
        conv_layer_cnt <= 0;
    else if(conv_layer_finish) begin
        if(conv_layer_cnt == 9)
            conv_layer_cnt <= 0;
        else
            conv_layer_cnt <= conv_layer_cnt + 1;
    end
end

//根据当前所处的控制周期进行参数设置
reg [10:0] ofm_list; 
always @(*) begin
    case(conv_layer_cnt)
        4'd0: ofm_list = 16;
        4'd1: ofm_list = 32;
        4'd2: ofm_list = 64;
        4'd3: ofm_list = 128;
        4'd4: ofm_list = 256;
        4'd5: ofm_list = 512;
        4'd6: ofm_list = 1024;
        4'd7: ofm_list = 256;
        4'd8: ofm_list = 512;
        4'd9: ofm_list = 72;
        default: ofm_list = 16;
    endcase
end

reg [10:0] ifm_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: ifm_list = 8;
        4'd1: ifm_list = 16;
        4'd2: ifm_list = 32;
        4'd3: ifm_list = 64;
        4'd4: ifm_list = 128;
        4'd5: ifm_list = 256;
        4'd6: ifm_list = 512;
        4'd7: ifm_list = 1024;
        4'd8: ifm_list = 256;
        4'd9: ifm_list = 512;
        default: ifm_list = 8;
    endcase
end

reg [15:0] scale_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: scale_list = 29987;
        4'd1: scale_list = 16897;
        4'd2: scale_list = 29843;
        4'd3: scale_list = 22453;
        4'd4: scale_list = 21102;
        4'd5: scale_list = 28510;
        4'd6: scale_list = 21649;
        4'd7: scale_list = 16535;
        4'd8: scale_list = 21696;
        4'd9: scale_list = 21411;
        default: scale_list = 29987;
    endcase
end

reg [3:0] shift_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: shift_list = 10;
        4'd1: shift_list = 7;
        4'd2: shift_list = 8;
        4'd3: shift_list = 7;
        4'd4: shift_list = 7;
        4'd5: shift_list = 8;
        4'd6: shift_list = 9;
        4'd7: shift_list = 6;
        4'd8: shift_list = 8;
        4'd9: shift_list = 8;
        default: shift_list = 10;
    endcase
end

reg [7:0] zp_in_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: zp_in_list = 0;
        4'd1: zp_in_list = 12;
        4'd2: zp_in_list = 33;
        4'd3: zp_in_list = 28;
        4'd4: zp_in_list = 14;
        4'd5: zp_in_list = 11;
        4'd6: zp_in_list = 17;
        4'd7: zp_in_list = 12;
        4'd8: zp_in_list = 13;
        4'd9: zp_in_list = 12;
        default: zp_in_list = 0;
    endcase
end

reg [7:0] zp_out_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: zp_out_list = 65;
        4'd1: zp_out_list = 98;
        4'd2: zp_out_list = 94;
        4'd3: zp_out_list = 70;
        4'd4: zp_out_list = 61;
        4'd5: zp_out_list = 77;
        4'd6: zp_out_list = 64;
        4'd7: zp_out_list = 67;
        4'd8: zp_out_list = 66;
        4'd9: zp_out_list = 91;
        default: zp_out_list = 65;
    endcase
end

reg [7:0] zp_act_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: zp_act_list = 12;
        4'd1: zp_act_list = 33;
        4'd2: zp_act_list = 28;
        4'd3: zp_act_list = 14;
        4'd4: zp_act_list = 11;
        4'd5: zp_act_list = 17;
        4'd6: zp_act_list = 12;
        4'd7: zp_act_list = 13;
        4'd8: zp_act_list = 12;
        4'd9: zp_act_list = 91;
        default: zp_act_list = 12;
    endcase
end

reg [2:0] sel_in_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: sel_in_list = 5;
        4'd1: sel_in_list = 4;
        4'd2: sel_in_list = 3;
        4'd3: sel_in_list = 2;
        4'd4: sel_in_list = 1;
        4'd5: sel_in_list = 0;
        4'd6: sel_in_list = 0;
        4'd7: sel_in_list = 0;
        4'd8: sel_in_list = 0;
        4'd9: sel_in_list = 0;
        default: sel_in_list = 5;
    endcase
end

reg pool_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: pool_list = 1;
        4'd1: pool_list = 1;
        4'd2: pool_list = 1;
        4'd3: pool_list = 1;
        4'd4: pool_list = 1;
        4'd5: pool_list = 1;
        4'd6: pool_list = 0;
        4'd7: pool_list = 0;
        4'd8: pool_list = 0;
        4'd9: pool_list = 0;
        default: pool_list = 1;
    endcase
end

reg stride_list;
always @(*) begin
    case(conv_layer_cnt)
        4'd0: stride_list = 0;
        4'd1: stride_list = 0;
        4'd2: stride_list = 0;
        4'd3: stride_list = 0;
        4'd4: stride_list = 0;
        4'd5: stride_list = 1;
        4'd6: stride_list = 0;
        4'd7: stride_list = 0;
        4'd8: stride_list = 0;
        4'd9: stride_list = 0;
        default: stride_list = 0;
    endcase
end


wire [7:0] ofm_batch;
wire [7:0] ifm_batch;
assign ofm_batch = ofm_list[10:3];
assign ifm_batch = ifm_list[10:3];

wire [2:0] sel;
assign sel = sel_in_list;

wire [31:0] reg_conv_len_sel_relu_sel;
wire [31:0] reg_pool_config;
wire [31:0] reg_scale_shift;
wire [31:0] reg_zp_out_in;
assign reg_conv_len_sel_relu_sel = {15'd0,`relu_type,3'd0,sel,10'd0};
assign reg_pool_config = {16'd0,stride_list,9'd0,pool_list,5'd0};
assign reg_scale_shift = {12'd0,shift_list,scale_list};
assign reg_zp_out_in = {8'd0,zp_act_list,zp_out_list,zp_in_list};

reg [31:0] ifm_ddr_base_addr0;
reg [31:0] ifm_ddr_base_addr1;
reg [31:0] ofm_ddr_base_addr;
reg [31:0] wgt_ddr_base_addr;
reg [31:0] bia_ddr_base_addr;
reg [31:0] lky_ddr_base_addr;
always @(*) begin
    case(conv_layer_cnt)
        4'd0:begin
            ifm_ddr_base_addr0 = `ifmInBuf0;
            ifm_ddr_base_addr1 = `ifmInBuf1;
            ofm_ddr_base_addr  = `FM_BUF_1;
            wgt_ddr_base_addr  = `WEIGHT0;
            bia_ddr_base_addr  = `BIAS0;
            lky_ddr_base_addr  = `LEAKY0;
        end
        4'd1:begin
            ifm_ddr_base_addr0 = `FM_BUF_1;
            ifm_ddr_base_addr1 = `FM_BUF_1;
            ofm_ddr_base_addr  = `FM_BUF_0;
            wgt_ddr_base_addr  = `WEIGHT1;
            bia_ddr_base_addr  = `BIAS1;
            lky_ddr_base_addr  = `LEAKY1;
        end
        4'd2:begin
            ifm_ddr_base_addr0 = `FM_BUF_0;
            ifm_ddr_base_addr1 = `FM_BUF_0;
            ofm_ddr_base_addr  = `FM_BUF_1;
            wgt_ddr_base_addr  = `WEIGHT2;
            bia_ddr_base_addr  = `BIAS2;
            lky_ddr_base_addr  = `LEAKY2;
        end
        4'd3:begin
            ifm_ddr_base_addr0 = `FM_BUF_1;
            ifm_ddr_base_addr1 = `FM_BUF_1;
            ofm_ddr_base_addr  = `FM_BUF_0;
            wgt_ddr_base_addr  = `WEIGHT3;
            bia_ddr_base_addr  = `BIAS3;
            lky_ddr_base_addr  = `LEAKY3;
        end
        4'd4:begin
            ifm_ddr_base_addr0 = `FM_BUF_0;
            ifm_ddr_base_addr1 = `FM_BUF_0;
            ofm_ddr_base_addr  = `FM_BUF_1;
            wgt_ddr_base_addr  = `WEIGHT4;
            bia_ddr_base_addr  = `BIAS4;
            lky_ddr_base_addr  = `LEAKY4;
        end
        4'd5:begin
            ifm_ddr_base_addr0 = `FM_BUF_1;
            ifm_ddr_base_addr1 = `FM_BUF_1;
            ofm_ddr_base_addr  = `FM_BUF_0;
            wgt_ddr_base_addr  = `WEIGHT5;
            bia_ddr_base_addr  = `BIAS5;
            lky_ddr_base_addr  = `LEAKY5;
        end
        4'd6:begin
            ifm_ddr_base_addr0 = `FM_BUF_0;
            ifm_ddr_base_addr1 = `FM_BUF_0;
            ofm_ddr_base_addr  = `FM_BUF_1;
            wgt_ddr_base_addr  = `WEIGHT6;
            bia_ddr_base_addr  = `BIAS6;
            lky_ddr_base_addr  = `LEAKY6;
        end
        4'd7:begin
            ifm_ddr_base_addr0 = `FM_BUF_1;
            ifm_ddr_base_addr1 = `FM_BUF_1;
            ofm_ddr_base_addr  = `FM_BUF_0;
            wgt_ddr_base_addr  = `WEIGHT7;
            bia_ddr_base_addr  = `BIAS7;
            lky_ddr_base_addr  = `LEAKY7;
        end
        4'd8:begin
            ifm_ddr_base_addr0 = `FM_BUF_0;
            ifm_ddr_base_addr1 = `FM_BUF_0;
            ofm_ddr_base_addr  = `FM_BUF_1;
            wgt_ddr_base_addr  = `WEIGHT8;
            bia_ddr_base_addr  = `BIAS8;
            lky_ddr_base_addr  = `LEAKY8;
        end
        4'd9:begin
            ifm_ddr_base_addr0 = `FM_BUF_1;
            ifm_ddr_base_addr1 = `FM_BUF_1;
            ofm_ddr_base_addr  = `FM_BUF_2;
            wgt_ddr_base_addr  = `WEIGHT9;
            bia_ddr_base_addr  = `BIAS9;
            lky_ddr_base_addr  = `LEAKY9;
        end
        default:begin
            ifm_ddr_base_addr0 = `ifmInBuf0;
            ifm_ddr_base_addr1 = `ifmInBuf1;
            ofm_ddr_base_addr  = `FM_BUF_1;
            wgt_ddr_base_addr  = `WEIGHT0;
            bia_ddr_base_addr  = `BIAS0;
            lky_ddr_base_addr  = `LEAKY0;
        end
    endcase
end

reg        ifm_sel;
wire [31:0] ifm_ddr_base_addr;
assign ifm_ddr_base_addr = ifm_sel ? ifm_ddr_base_addr1 : ifm_ddr_base_addr0;



reg resize_load_t;
assign resize_load = resize_load_t;


reg [8:0]  fm_col;
reg [8:0]  fm_row;
reg [17:0] fm_size;
always @(*) begin
    case(conv_layer_cnt)
        4'd0:begin
            fm_col  = 418;
            fm_row  = 258;
            fm_size = 107844;
        end
        4'd1:begin
            fm_col  = 210;
            fm_row  = 130;
            fm_size = 27300;
        end
        4'd2:begin
            fm_col  = 106;
            fm_row  = 66;
            fm_size = 6996;
        end
        4'd3:begin
            fm_col  = 54;
            fm_row  = 34;
            fm_size = 1836;
        end
        4'd4:begin
            fm_col  = 28;
            fm_row  = 18;
            fm_size = 504;
        end
        4'd5:begin
            fm_col  = 15;
            fm_row  = 10;
            fm_size = 150;
        end
        4'd6:begin
            fm_col  = 15;
            fm_row  = 10;
            fm_size = 150;
        end
        4'd7:begin
            fm_col  = 15;
            fm_row  = 10;
            fm_size = 150;
        end
        4'd8:begin
            fm_col  = 15;
            fm_row  = 10;
            fm_size = 150;
        end
        4'd9:begin
            fm_col  = 15;
            fm_row  = 10;
            fm_size = 150;
        end
        default:begin
            fm_col  = 418;
            fm_row  = 258;
            fm_size = 107844;
        end
    endcase
end

reg [5:0] fm_div;
reg [5:0] fm_div_cnt;
reg [5:0] fm_res;
always @(*) begin
    case(conv_layer_cnt)
        4'd0:begin
            fm_div = 6;
            fm_div_cnt = 43;
            fm_res = 6;
        end
        4'd1:begin
            fm_div = 16;
            fm_div_cnt = 9;
            fm_res = 6;
        end
        4'd2:begin
            fm_div = 36;
            fm_div_cnt = 2;
            fm_res = 30;
        end
        4'd3:begin
            fm_div = 34;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        4'd4:begin
            fm_div = 18;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        4'd5:begin
            fm_div = 10;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        4'd6:begin
            fm_div = 10;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        4'd7:begin
            fm_div = 10;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        4'd8:begin
            fm_div = 10;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        4'd9:begin
            fm_div = 10;
            fm_div_cnt = 1;
            fm_res = 0;
        end
        default:begin
            fm_div = 6;
            fm_div_cnt = 43;
            fm_res = 6;
        end
    endcase
end

reg ofm_recv_half;
reg [7:0] fm_col_half;
reg [7:0] fm_row_half;
reg [15:0] fm_size_half;
always @(*) begin
    case(conv_layer_cnt)
        4'd0:begin
            ofm_recv_half = 1;
            fm_col_half = 210;
            fm_row_half = 130;
            fm_size_half = 27300;
        end
        4'd1:begin
            ofm_recv_half = 1;
            fm_col_half = 106;
            fm_row_half = 66;
            fm_size_half = 6996;
        end
        4'd2:begin
            ofm_recv_half = 1;
            fm_col_half = 54;
            fm_row_half = 34;
            fm_size_half = 1836;
        end
        4'd3:begin
            ofm_recv_half = 1;
            fm_col_half = 28;
            fm_row_half = 18;
            fm_size_half = 504;
        end
        4'd4:begin
            ofm_recv_half = 1;
            fm_col_half = 15;
            fm_row_half = 10;
            fm_size_half = 150;
        end
        4'd5:begin
            ofm_recv_half = 0;
            fm_col_half = 8;
            fm_row_half = 6;
            fm_size_half = 48;
        end
        4'd6:begin
            ofm_recv_half = 0;
            fm_col_half = 8;
            fm_row_half = 6;
            fm_size_half = 48;
        end
        4'd7:begin
            ofm_recv_half = 0;
            fm_col_half = 8;
            fm_row_half = 6;
            fm_size_half = 48;
        end
        4'd8:begin
            ofm_recv_half = 0;
            fm_col_half = 8;
            fm_row_half = 6;
            fm_size_half = 48;
        end
        4'd9:begin
            ofm_recv_half = 0;
            fm_col_half = 8;
            fm_row_half = 6;
            fm_size_half = 48;
        end
        default:begin
            ofm_recv_half = 1;
            fm_col_half = 210;
            fm_row_half = 130;
            fm_size_half = 27300;
        end
    endcase
end

wire [4:0] fm_div_half;
wire [4:0] fm_res_half;
assign fm_div_half = fm_div >> 1;
assign fm_res_half = fm_res >> 1;

//采集ap_done上升沿
reg ap_done_t0;
reg ap_done_t1;
wire ap_done_up;
always @(posedge clk) begin
    if(rst) begin
        ap_done_t0 <= 0;
        ap_done_t1 <= 0;
    end
    else begin
        ap_done_t0 <= ap_done;
        ap_done_t1 <= ap_done_t0;
    end
end
assign ap_done_up = ~ap_done_t1 & ap_done_t0;

//推理状态机
reg [31:0] wgt_addr_send;
reg [15:0] wgt_addr_read;
reg [15:0] bia_addr_read;
reg        last_buf_sel;
reg [7:0]  iter_ifm_pre;
reg [7:0]  iter_ofm_pre;
reg [7:0]  iter_div_pre;
reg [7:0]  iter_ifm_post;
reg [7:0]  iter_ofm_post;
reg [7:0]  iter_div_post;

// reg [7:0]  iter_ofm_post_t;
// reg [7:0]  iter_div_post_t;
// reg [7:0]  iter_ifm_post_t;
// reg [7:0]  iter_div_pre_t;

reg        ifm_send_task_enable;

reg [31:0] ifm_addr_fmbase;
reg [31:0] ifm_addr_offset;
reg [31:0] ifm_send_len;

reg [31:0]   reg_static;
reg [31:0]   reg_task;

reg          ofm_recv_task_enable;
reg [31:0]   ofm_addr_fmbase;
reg [31:0]   ofm_addr_offset;
reg [31:0]   ofm_recv_len;

reg          wgt_send_task_enable;
reg  [15:0]  wgt_addr_read_t;


reg [5:0]  fm_res_t2;
reg [14:0] fm_div_col;
reg [5:0]  fm_div_t2;
always @(posedge clk) begin
    if(rst) begin
        fm_res_t2 <= 0;
        fm_div_col <= 0;
        fm_div_t2 <= 0;  
    end
    else begin
        fm_res_t2 <= fm_res + 2;
        fm_div_col <= fm_div*fm_col;
        fm_div_t2 <= fm_div + 2;
    end
end

reg [4:0]   fm_div_half_t1;
reg [4:0]   fm_res_half_t1;
reg [15:0]  iter_div_half_t1;
always @(posedge clk) begin
    if(rst) begin
        fm_div_half_t1 <= 0;
        fm_res_half_t1 <= 0;
        iter_div_half_t1 <= 0;
    end
    else begin
        fm_div_half_t1 <= fm_div_half + 1;
        fm_res_half_t1 <= fm_res_half + 1;
        iter_div_half_t1 <= iter_div_post*fm_div_half+1;
    end
end

reg  [4:0]   fm_div_t1;
reg  [4:0]   fm_res_t1;
reg  [15:0]  iter_div_t1;
always @(posedge clk) begin
    if(rst) begin
        fm_div_t1 <= 0;
        fm_res_t1 <= 0;
        iter_div_t1 <= 0;
    end
    else begin
        fm_div_t1 <= fm_div + 1;
        fm_res_t1 <= fm_res + 1;
        iter_div_t1 <= iter_div_post*fm_div+1;
    end
end

//OFM0
reg [31:0] fm_row_half_res_half_t1xfm_col_half;
reg [31:0] iter_div_half_t1xfm_col_half;
always @(posedge clk) begin
    if(rst) begin
        fm_row_half_res_half_t1xfm_col_half <= 0;
        iter_div_half_t1xfm_col_half <= 0;
    end
    else begin
        fm_row_half_res_half_t1xfm_col_half <= (fm_row_half-fm_res_half_t1)*fm_col_half;
        iter_div_half_t1xfm_col_half <= iter_div_half_t1*fm_col_half;
    end
end

//OFM1
reg [31:0] fm_row_fm_res_t1xfm_col;
reg [31:0] iter_div_t1xfm_col;
reg [8:0]  fm_row_fm_res_t1;
always @(posedge clk) begin
    if(rst) begin
        fm_row_fm_res_t1xfm_col <= 0;
        iter_div_t1xfm_col <= 0;
        fm_row_fm_res_t1 <= 0;
    end
    else begin
        fm_row_fm_res_t1 <= fm_row - fm_res_t1;
        fm_row_fm_res_t1xfm_col <= fm_row_fm_res_t1*fm_col;
        iter_div_t1xfm_col <= iter_div_t1*fm_col;
    end
end

//IFM
reg [31:0] fm_row_fm_res_t2xfm_col;
reg [31:0] iter_div_prexfm_div_col;
reg [8:0]  fm_row_fm_res_t2;
always @(posedge clk) begin
    if(rst) begin
        fm_row_fm_res_t2xfm_col <= 0;
        iter_div_prexfm_div_col <= 0;
        fm_row_fm_res_t2 <= 0;
    end
    else begin
        fm_row_fm_res_t2 <= fm_row - fm_res_t2;
        fm_row_fm_res_t2xfm_col <= fm_row_fm_res_t2*fm_col;
        iter_div_prexfm_div_col <= iter_div_pre*fm_div_col;
    end
end

//地址计算
reg [31:0]   ofm_addr_recv;
reg [31:0]   ofm_addr_t;
always @(posedge clk) begin
    if(rst) begin
        ofm_addr_t <= 0;
        ofm_addr_recv <= 0;
    end
    else begin
        ofm_addr_t <= (ofm_addr_fmbase+ofm_addr_offset)<<3;
        ofm_addr_recv <= ofm_ddr_base_addr + ofm_addr_t;
    end
end


reg [31:0] ifm_addr_send;
reg [31:0] ifm_addr_t;
always @(posedge clk) begin
    if(rst) begin
        ifm_addr_t <= 0;
        ifm_addr_send <= 0;
    end
    else begin
        ifm_addr_t <= (ifm_addr_fmbase+ifm_addr_offset)<<3;
        ifm_addr_send <= ifm_ddr_base_addr+ifm_addr_t;
    end
end


wire [7:0]  iter_ofm_post_t;
wire [7:0]  iter_div_post_t;
wire [7:0]  iter_ifm_post_t;
wire [7:0]  iter_div_pre_t;
assign iter_ofm_post_t = ofm_batch - iter_ofm_post;
assign iter_div_post_t = fm_div_cnt - iter_div_post;
assign iter_ifm_post_t = ifm_batch - iter_ifm_post;
assign iter_div_pre_t = fm_div_cnt - iter_div_pre;

// reg [7:0]  iter_ofm_post_t;
// reg [7:0]  iter_div_post_t;
// reg [7:0]  iter_ifm_post_t;
// reg [7:0]  iter_div_pre_t;
// always@(posedge clk) begin
//     if(rst) begin
//         iter_ofm_post_t <= 0;
//         iter_div_post_t <= 0;
//         iter_ifm_post_t <= 0;
//         iter_div_pre_t <= 0;
//     end    
//     else begin
//         iter_ofm_post_t <= ofm_batch - iter_ofm_post;
//         iter_div_post_t <= fm_div_cnt - iter_div_post;
//         iter_ifm_post_t <= ifm_batch - iter_ifm_post;
//         iter_div_pre_t <= fm_div_cnt - iter_div_pre;
//     end
// end

reg  [5:0] state;
reg  [5:0] cnt;
always @(posedge clk) begin
    if(rst) begin
        state <= 0;
        wgt_addr_send <= 0;
        wgt_addr_read <= 0;
        bia_addr_read <= 0;
        last_buf_sel  <= 0;
        iter_ifm_pre  <= 0;
        iter_ofm_pre  <= 0;
        iter_div_pre  <= 0;
        iter_ifm_post <= 0;
        iter_ofm_post <= 0;
        iter_div_post <= 0;
        cnt <= 0;
        yolo_en_t <= 0;
        reg0_t <= 0;
        reg1_t <= 0;
        reg2_t <= 0;
        reg3_t <= 0;
        reg4_t <= 0;
        reg5_t <= 0;
        reg6_t <= 0;
        reg7_t <= 0;
        ifm_send_task_enable <= 0;
        ifm_addr_fmbase <= 0;
        ifm_addr_offset <= 0;
        ifm_send_len <= 0;
        reg_static <= 0; 
        reg_task <= 0;
        ofm_recv_task_enable <= 0;
        ofm_addr_fmbase <= 0;
        ofm_addr_offset <= 0;
        ofm_recv_len <= 0;
        wgt_send_task_enable <= 0;
        wgt_addr_read_t <= 0;
        resize_load_t <= 0;
        ifm_sel <= 1;
    end
    else begin
        case(state)
            //INIT_TASK
            `INIT_IDLE:begin
                conv_layer_finish <= 0;
                if(cnt == 5) begin   //保证组合逻辑完整
                    cnt <= 0;
                    state <= `INIT_SEND_DMA_BIA_0;
                end
                else 
                    cnt <= cnt + 1;
            end
            `INIT_SEND_DMA_BIA_0:begin
                wgt_addr_send <= wgt_ddr_base_addr;
                wgt_addr_read <= 0;
                bia_addr_read <= 0;
                last_buf_sel  <= 0;
                iter_ifm_pre  <= 0;
                iter_ofm_pre  <= 0;
                iter_div_pre  <= 0;
                iter_ifm_post <= 0;
                iter_ofm_post <= 0;
                iter_div_post <= 0;
                reg4_t <= bia_ddr_base_addr;
                reg5_t <= ofm_batch << 6;
                reg0_t <= `RECV_ENABLE|`TASK_VALID|`BIAS_BUF_SEL;
                cnt <= 0;
                state <= `INIT_SEND_DMA_BIA_1;
            end
            `INIT_SEND_DMA_BIA_1:begin
                if(cnt == 5) begin
                    state <= `INIT_SEND_DMA_BIA_2;
                    cnt <= 0;
                    reg0_t <= `BIAS_BUF_SEL;
                end
                else 
                    cnt <= cnt + 1;
            end
            `INIT_SEND_DMA_BIA_2:begin
                if(ap_done_up)
                    state <= `INIT_SEND_DMA_LKY_0;
                else 
                    state <= `INIT_SEND_DMA_BIA_2;
            end
            `INIT_SEND_DMA_LKY_0:begin
                reg4_t <= lky_ddr_base_addr;
                reg5_t <= 256*8;
                reg0_t <= `RECV_ENABLE|`TASK_VALID|`LEAKY_RELU_BUF;
                cnt <= 0;
                state <= `INIT_SEND_DMA_LKY_1;
            end
            `INIT_SEND_DMA_LKY_1:begin
                if(cnt == 5) begin
                    state <= `INIT_SEND_DMA_LKY_2;
                    cnt <= 0;
                    reg0_t <= `LEAKY_RELU_BUF;
                end
                else 
                    cnt <= cnt + 1;
            end
            `INIT_SEND_DMA_LKY_2:begin
                if(ap_done_up)
                    state <= `INIT_SEND_DMA_WGT_0;
                else 
                    state <= `INIT_SEND_DMA_LKY_2;
            end
            `INIT_SEND_DMA_WGT_0:begin
                reg4_t <= wgt_ddr_base_addr;
                reg5_t <= `WEIGHT_LEN*64*9;
                reg0_t <= `RECV_ENABLE|`TASK_VALID|`WEIGHT_BUF_SEL;
                cnt <= 0;
                state <= `INIT_SEND_DMA_WGT_1;
            end
            `INIT_SEND_DMA_WGT_1:begin
                if(cnt == 5) begin
                    state <= `INIT_SEND_DMA_WGT_2;
                    cnt <= 0;
                    reg0_t <= `WEIGHT_BUF_SEL;
                end
                else 
                    cnt <= cnt + 1;
            end
            `INIT_SEND_DMA_WGT_2:begin
                if(ap_done_up) begin
                    state <= `INIT_NEXT_IFM_ADDR_0;
                    reg1_t <= reg_scale_shift;
                    reg2_t <= reg_zp_out_in;
                end
                else 
                    state <= `INIT_SEND_DMA_WGT_2;
            end
            `INIT_NEXT_IFM_ADDR_0:begin
                if(iter_ofm_post_t!=1 || iter_div_post_t!=1 || iter_ifm_post_t!=1) begin
                    ifm_send_task_enable <= 1;
                    state <= `INIT_NEXT_IFM_ADDR_1;
                end
                else begin
                    ifm_send_task_enable <= 0;
                    state <= `INIT_SET_REG0;
                end
            end
            `INIT_NEXT_IFM_ADDR_1:begin
                if(fm_size > 256)
                    ifm_addr_fmbase <= iter_ifm_pre*fm_size;
                else 
                    ifm_addr_fmbase <= iter_ifm_pre << 8;
                if(fm_div_cnt == 1) begin
                    ifm_addr_offset <= 0;
			        ifm_send_len <= fm_size<<3;
                end 
                else begin
                    if(iter_div_pre_t == 1) begin
                        ifm_addr_offset <= fm_row_fm_res_t2xfm_col;
                        ifm_send_len <= (fm_res_t2*fm_col)<<3;
                    end
                    else begin
                        ifm_addr_offset <= iter_div_prexfm_div_col;
				        ifm_send_len <= (fm_div_t2*fm_col)<<3;
                    end
                end
                state <= `INIT_SET_REG0;
                reg_static <= reg_conv_len_sel_relu_sel;
            end
            `INIT_SET_REG0:begin
                if(iter_ifm_post == 0)
		            reg_static <= reg_static | `FIRST_CONV;
                state <= `INIT_SET_REG1;
            end
            `INIT_SET_REG1:begin
                if(iter_ifm_post == ifm_batch-1)
                    reg_static <= reg_static | `LAST_CONV | reg_pool_config;
                state <= `INIT_SET_REG2;
            end
            `INIT_SET_REG2:begin
                if(!last_buf_sel)
                    reg_static <= reg_static | `IFM_SEL;
                last_buf_sel <= ~last_buf_sel;
                state <= `INIT_SET_REG3;
            end
            `INIT_SET_REG3:begin
                if(fm_div_cnt==1)
                    reg_static <= {2'b00,fm_div,reg_static[23:15],`OFM_SEND_WHOLE,reg_static[12:0]};
                else begin
                    if(iter_div_post==0)
                        reg_static <= {2'b00,fm_div_t2,reg_static[23:15],`OFM_SEND_NO_TAIL,reg_static[12:0]};
		            else if(iter_div_post_t == 1)
                        reg_static <= {2'b00,fm_res_t2,reg_static[23:15],`OFM_SEND_NO_HEAD,reg_static[12:0]};
                    else
                        reg_static <= {2'b00,fm_div_t2,reg_static[23:15],`OFM_SEND_REDUCE,reg_static[12:0]};
                end
                if(iter_ofm_post_t == 1 && iter_div_post_t == 1 && iter_ifm_post_t == 1)
                    reg_task <= `CONV_START_CMD | `TASK_VALID;
                else if(iter_ofm_pre == 0 && iter_div_pre == 0 && iter_ifm_pre == 0)
                    reg_task <= `RECV_ENABLE | `TASK_VALID;
                else
                    reg_task <= `RECV_ENABLE | `CONV_START_CMD | `TASK_VALID;
                state <= `IFM_SEND_IFM0;
            end


            //IFM_CONV_TASK
            `IFM_SEND_IFM0:begin
                if(ifm_send_task_enable) begin
                    reg4_t <= ifm_addr_send;
                    reg5_t <= ifm_send_len;
                end
                reg3_t <= {bia_addr_read,wgt_addr_read};
                reg0_t <= reg_static | reg_task;
                cnt <= 0;
                state <= `IFM_SEND_IFM1;
            end
            `IFM_SEND_IFM1:begin
                if(cnt == 5) begin
                    cnt <= 0;
                    state <= `IFM_SEND_IFM2;
                    reg0_t <= reg_static;
                end
                else 
                    cnt <= cnt + 1;
            end
            `IFM_SEND_IFM2:begin
                if(ap_done_up) 
                    state <= `IFM_NEXT_OFM_ADDR_0;
                else 
                    state <= `IFM_SEND_IFM2;
            end
            `IFM_NEXT_OFM_ADDR_0:begin
                if(iter_ifm_post_t == 1) begin
                    ofm_recv_task_enable <= 1;
                    state <= `IFM_NEXT_OFM_ADDR_1;
                end
                else begin
                    ofm_recv_task_enable <= 0;
                    state <= `IFM_NEXT_WGT_ADDR;
                end
            end
            `IFM_NEXT_OFM_ADDR_1:begin
                if(ofm_recv_half)
                    state <= `IFM_NEXT_OFM0_ADDR_0;
                else 
                    state <= `IFM_NEXT_OFM1_ADDR_0;
            end
            `IFM_NEXT_OFM0_ADDR_0:begin
                if(fm_size_half>256) 
                    ofm_addr_fmbase <= iter_ofm_post*fm_size_half;
			    else 
                    ofm_addr_fmbase <= iter_ofm_post << 8;
                if(fm_div_cnt==1) begin
                    ofm_addr_offset <= 0;
                    ofm_recv_len <= fm_size_half<<3;
                    state <= `IFM_NEXT_WGT_ADDR;
                end
                else begin
                    state <= `IFM_NEXT_OFM0_ADDR_1;
                end
            end
            `IFM_NEXT_OFM0_ADDR_1:begin
                state <= `IFM_NEXT_WGT_ADDR;
                if(iter_div_post == 0) begin
                    ofm_addr_offset <= 0;
                    ofm_recv_len <= (fm_div_half_t1*fm_col_half)<<3;
                end
                else if(iter_div_post_t == 1) begin
                    ofm_addr_offset <= fm_row_half_res_half_t1xfm_col_half;
                    ofm_recv_len <= (fm_res_half_t1*fm_col_half)<<3;
                end
                else begin
                    ofm_addr_offset <= iter_div_half_t1xfm_col_half;
                    ofm_recv_len <= (fm_div_half*fm_col_half)<<3;
                end
            end
            `IFM_NEXT_OFM1_ADDR_0:begin
                if(fm_size > 256) 
                    ofm_addr_fmbase <= iter_ofm_post*fm_size;
			    else 
                    ofm_addr_fmbase <= iter_ofm_post << 8;
                if(fm_div_cnt == 1) begin
                    ofm_addr_offset <= 0;
                    ofm_recv_len <= fm_size<<3;
                    state <= `IFM_NEXT_WGT_ADDR;
                end
                else begin
                    state <= `IFM_NEXT_OFM1_ADDR_1;
                end
            end
            `IFM_NEXT_OFM1_ADDR_1:begin
                state <= `IFM_NEXT_WGT_ADDR;
                if(iter_div_post == 0) begin
                    ofm_addr_offset <= 0;
                    ofm_recv_len <= (fm_div_t1*fm_col)<<3;
                end
                else if(iter_div_post_t == 1) begin
                    ofm_addr_offset <= fm_row_fm_res_t1xfm_col;
                    ofm_recv_len <= (fm_res_t1*fm_col)<<3;
                end
                else begin
                    ofm_addr_offset <= iter_div_t1xfm_col;
                    ofm_recv_len <= (fm_div*fm_col)<<3;
                end
            end
            `IFM_NEXT_WGT_ADDR:begin
                if(wgt_addr_read == `WEIGHT_LEN-1 && iter_div_post_t == 1 && iter_ofm_post_t != 1) begin
                    wgt_send_task_enable <= 1;
                    wgt_addr_send <= wgt_addr_send+`WEIGHT_LEN*64*9;
                    wgt_addr_read <= 0;
                end
                else 
                    wgt_send_task_enable <= 0;
                if(!ofm_recv_task_enable)
                    state <= `IFM_UPDATA_ITER_0;
                else
                    state <= `OFM_WGT_STATE_0;
            end
            `IFM_UPDATA_ITER_0:begin
                iter_ifm_post <= iter_ifm_pre;
                iter_div_post <= iter_div_pre;
                iter_ofm_post <= iter_ofm_pre;
                iter_ifm_pre <= iter_ifm_pre + 1;
                state <= `IFM_UPDATA_ITER_1;
            end
            `IFM_UPDATA_ITER_1:begin
                if(iter_ifm_pre == ifm_batch) begin
                    iter_ifm_pre <= 0;
                    iter_div_pre <= iter_div_pre + 1;
                    state <= `IFM_UPDATA_ITER_2;
                end
                else 
                    state <= `IFM_NEXT_IFM_ADDR_0;
            end
            `IFM_UPDATA_ITER_2:begin
                if(iter_div_pre == fm_div_cnt) begin
                    iter_div_pre <= 0;
                    iter_ofm_pre <= iter_ofm_pre + 1;
                end 
                state <= `IFM_NEXT_IFM_ADDR_0;
            end
           `IFM_NEXT_IFM_ADDR_0:begin
                if(iter_ofm_post_t!=1 || iter_div_post_t!=1 || iter_ifm_post_t!=1) begin
                    ifm_send_task_enable <= 1;
                    state <= `IFM_NEXT_IFM_ADDR_1;
                end
                else begin
                    ifm_send_task_enable <= 0;
                    state <= `IFM_SET_REG0;
                end
            end
            `IFM_NEXT_IFM_ADDR_1:begin
                if(fm_size > 256)
                    ifm_addr_fmbase <= iter_ifm_pre*fm_size;
                else 
                    ifm_addr_fmbase <= iter_ifm_pre << 8;
                if(fm_div_cnt == 1) begin
                    ifm_addr_offset <= 0;
			        ifm_send_len <= fm_size<<3;
                end 
                else begin
                    if(iter_div_pre_t == 1) begin
                        ifm_addr_offset <= fm_row_fm_res_t2xfm_col;
                        ifm_send_len <= (fm_res_t2*fm_col)<<3;
                    end
                    else begin
                        ifm_addr_offset <= iter_div_prexfm_div_col;
				        ifm_send_len <= (fm_div_t2*fm_col)<<3;
                    end
                end
                state <= `IFM_SET_REG0;
                reg_static <= reg_conv_len_sel_relu_sel;
            end
            `IFM_SET_REG0:begin
                if(iter_ifm_post == 0)
		            reg_static <= reg_static | `FIRST_CONV;
                state <= `IFM_SET_REG1;
            end
            `IFM_SET_REG1:begin
                if(iter_ifm_post == ifm_batch-1)
                    reg_static <= reg_static | `LAST_CONV | reg_pool_config;
                state <= `IFM_SET_REG2;
            end
            `IFM_SET_REG2:begin
                if(!last_buf_sel)
                    reg_static <= reg_static | `IFM_SEL;
                last_buf_sel <= ~last_buf_sel;
                state <= `IFM_SET_REG3;
            end
            `IFM_SET_REG3:begin
                if(fm_div_cnt==1)
                    reg_static <= {2'b00,fm_div,reg_static[23:15],`OFM_SEND_WHOLE,reg_static[12:0]};
                else begin
                    if(iter_div_post==0)
                        reg_static <= {2'b00,fm_div_t2,reg_static[23:15],`OFM_SEND_NO_TAIL,reg_static[12:0]};
		            else if(iter_div_post_t == 1)
                        reg_static <= {2'b00,fm_res_t2,reg_static[23:15],`OFM_SEND_NO_HEAD,reg_static[12:0]};
                    else
                        reg_static <= {2'b00,fm_div_t2,reg_static[23:15],`OFM_SEND_REDUCE,reg_static[12:0]};
                end
                if(iter_ofm_post_t == 1 && iter_div_post_t == 1 && iter_ifm_post_t == 1)
                    reg_task <= `CONV_START_CMD | `TASK_VALID;
                else if(iter_ofm_pre == 0 && iter_div_pre == 0 && iter_ifm_pre == 0)
                    reg_task <= `RECV_ENABLE | `TASK_VALID;
                else
                    reg_task <= `RECV_ENABLE | `CONV_START_CMD | `TASK_VALID;
                state <= `IFM_WGT_ADDR_READ_0;
            end
            `IFM_WGT_ADDR_READ_0:begin
                wgt_addr_read_t <= iter_ofm_post*ifm_batch+iter_ifm_post;
                state <= `IFM_WGT_ADDR_READ_1;
            end
            `IFM_WGT_ADDR_READ_1:begin
                wgt_addr_read <= wgt_addr_read_t & (`WEIGHT_LEN-1);
                bia_addr_read <= iter_ofm_post;
                state <= `OFM_WGT_STATE_0;
            end

            //OFM_WGT_TASK
            `OFM_WGT_STATE_0:begin
                if(ofm_recv_task_enable)
                    state <= `OFM_RECV_0;
                else 
                    state <= `OFM_WGT_STATE_1;
            end
            `OFM_RECV_0:begin
                if(conv_layer_cnt == 9)
                    yolo_en_t <= 1;
                reg6_t <= ofm_addr_recv;
                reg7_t <= ofm_recv_len;
                reg0_t <= reg_static | `SEND_ENABLE | `TASK_VALID;
                cnt <= 0;
                state <= `OFM_RECV_1;
            end
            `OFM_RECV_1:begin
                if(cnt == 5) begin
                    cnt = 0;
                    reg0_t <= reg_static;
                    state <= `OFM_RECV_2;
                end
                else 
                    cnt <= cnt + 1;
            end
            `OFM_RECV_2:begin
                if(ap_done_up)
                    state <= `OFM_RECV_3;
                else
                    state <= `OFM_RECV_2;
            end
            `OFM_RECV_3:begin
                if(iter_ofm_post_t == 1 && iter_div_post_t == 1 && iter_ifm_post_t == 1)
                    state <= `ALL_TASK_FINISH;
                else begin
                    state <= `OFM_UPDATA_ITER_0;
                    iter_ifm_post <= iter_ifm_pre;
                    iter_div_post <= iter_div_pre;
                    iter_ofm_post <= iter_ofm_pre;
                    iter_ifm_pre <= iter_ifm_pre + 1;
                end
            end
            `OFM_UPDATA_ITER_0:begin
                if(iter_ifm_pre == ifm_batch) begin
                    iter_ifm_pre <= 0;
                    iter_div_pre <= iter_div_pre + 1;
                    state <= `OFM_UPDATA_ITER_1;
                end
                else 
                    state <= `OFM_NEXT_IFM_ADDR_0;
            end
            `OFM_UPDATA_ITER_1:begin
                if(iter_div_pre == fm_div_cnt) begin
                    iter_div_pre <= 0;
                    iter_ofm_pre <= iter_ofm_pre + 1;
                end
                state <= `OFM_NEXT_IFM_ADDR_0;
            end
            `OFM_NEXT_IFM_ADDR_0:begin
                if(iter_ofm_post_t!=1 || iter_div_post_t!=1 || iter_ifm_post_t!=1) begin
                    ifm_send_task_enable <= 1;
                    state <= `OFM_NEXT_IFM_ADDR_1;
                end
                else begin
                    ifm_send_task_enable <= 0;
                    state <= `OFM_SET_REG0;
                end
            end
            `OFM_NEXT_IFM_ADDR_1:begin
                if(fm_size > 256)
                    ifm_addr_fmbase <= iter_ifm_pre*fm_size;
                else 
                    ifm_addr_fmbase <= iter_ifm_pre << 8;
                if(fm_div_cnt == 1) begin
                    ifm_addr_offset <= 0;
			        ifm_send_len <= fm_size<<3;
                end 
                else begin
                    if(iter_div_pre_t == 1) begin
                        ifm_addr_offset <= fm_row_fm_res_t2xfm_col;
                        ifm_send_len <= (fm_res_t2*fm_col)<<3;
                    end
                    else begin
                        ifm_addr_offset <= iter_div_prexfm_div_col;
				        ifm_send_len <= (fm_div_t2*fm_col)<<3;
                    end
                end
                state <= `OFM_SET_REG0;
                reg_static <= reg_conv_len_sel_relu_sel;
            end
            `OFM_SET_REG0:begin
                if(iter_ifm_post==0)
		            reg_static <= reg_static | `FIRST_CONV;
                state <= `OFM_SET_REG1;
            end
            `OFM_SET_REG1:begin
                if(iter_ifm_post == ifm_batch-1)
                    reg_static <= reg_static | `LAST_CONV | reg_pool_config;
                state <= `OFM_SET_REG2;
            end
            `OFM_SET_REG2:begin
                if(!last_buf_sel)
                    reg_static <= reg_static | `IFM_SEL;
                last_buf_sel <= ~last_buf_sel;
                state <= `OFM_SET_REG3;
            end
            `OFM_SET_REG3:begin
                if(fm_div_cnt==1)
                    reg_static <= {2'b00,fm_div,reg_static[23:15],`OFM_SEND_WHOLE,reg_static[12:0]};
                else begin
                    if(iter_div_post==0)
                        reg_static <= {2'b00,fm_div_t2,reg_static[23:15],`OFM_SEND_NO_TAIL,reg_static[12:0]};
		            else if(iter_div_post_t == 1)
                        reg_static <= {2'b00,fm_res_t2,reg_static[23:15],`OFM_SEND_NO_HEAD,reg_static[12:0]};
                    else
                        reg_static <= {2'b00,fm_div_t2,reg_static[23:15],`OFM_SEND_REDUCE,reg_static[12:0]};
                end
                if(iter_ofm_post_t == 1 && iter_div_post_t == 1 && iter_ifm_post_t == 1)
                    reg_task <= `CONV_START_CMD | `TASK_VALID;
                else if(iter_ofm_pre == 0 && iter_div_pre == 0 && iter_ifm_pre == 0)
                    reg_task <= `RECV_ENABLE | `TASK_VALID;
                else
                    reg_task <= `RECV_ENABLE | `CONV_START_CMD | `TASK_VALID;
                state <= `OFM_WGT_ADDR_READ_0;
            end
            `OFM_WGT_ADDR_READ_0:begin
                wgt_addr_read_t <= iter_ofm_post*ifm_batch+iter_ifm_post;
                state <= `OFM_WGT_ADDR_READ_1;
            end
            `OFM_WGT_ADDR_READ_1:begin
                wgt_addr_read <= wgt_addr_read_t & (`WEIGHT_LEN-1);
                bia_addr_read <= iter_ofm_post;
                state <= `OFM_WGT_STATE_1;
            end
            `OFM_WGT_STATE_1:begin
                if(wgt_send_task_enable)
                    state <= `WGT_SEND_0;
                else
                    state <= `IFM_SEND_IFM0;
            end
            `WGT_SEND_0:begin
                reg4_t <= wgt_addr_send;
                reg5_t <= `WEIGHT_LEN*64*9;
                reg0_t <= `RECV_ENABLE | `TASK_VALID | `WEIGHT_BUF_SEL;
                cnt <= 0;
                state <= `WGT_SEND_1;
            end
            `WGT_SEND_1:begin
                if(cnt == 5) begin
                    cnt <= 0;
                    state <= `WGT_SEND_2;
                    reg0_t <= `WEIGHT_BUF_SEL;
                end
                else 
                    cnt <= cnt + 1;
            end
            `WGT_SEND_2:begin
                if(ap_done_up) 
                    state <= `IFM_SEND_IFM0;
                else
                    state <= `WGT_SEND_2;
            end
            `ALL_TASK_FINISH:begin
                if(conv_layer_cnt == 9) begin
                    ifm_sel <= ~ifm_sel;
                    state <= `WAIT_YOLO_FINSH;
                end
                else begin
                    conv_layer_finish <= 1;
                    state <= `INIT_IDLE;
                end
            end
            `WAIT_YOLO_FINSH:begin
                if(yolo_layer_finish_up) 
                    state <= `WAIT_YOLO_CLR;  
                else 
                    state <= `WAIT_YOLO_FINSH;
            end
            `WAIT_YOLO_CLR:begin
                if(yolo_clr_up) begin
                    state <= `INIT_IDLE;  
                    conv_layer_finish <= 1;
                    resize_load_t <= ~resize_load_t;
                    yolo_en_t <= 0;
                end
                else 
                    state <= `WAIT_YOLO_CLR;
            end
        endcase
    end
end

endmodule