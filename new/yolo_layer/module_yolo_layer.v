
module module_yolo_layer(
    input clk,
    input rst,
    input e203_clk,
    input e203_rst_n,

    input [63:0] dma_wdata,
    input        dma_wvalid,
    input        dma_wbusy,

    input        yolo_layer_en,
    output reg   yolo_layer_finish,  
    input        yolo_clr,

	input [5:0] send_addr,
	output reg [31:0] send_data
);


//采集dma_wbusy的上升沿
reg dma_wbusy_t0;
wire dma_wbusy_up;
wire dma_wbusy_down;
assign dma_wbusy_up = (~dma_wbusy_t0 & dma_wbusy);
assign dma_wbusy_down = (~dma_wbusy & dma_wbusy_t0);
always @(posedge clk) begin
    if(rst)
        dma_wbusy_t0 <= 0;              
    else 
        dma_wbusy_t0 <= dma_wbusy;
end

//采集yolo_layer_en上升沿
reg yolo_layer_en_t0;
reg yolo_layer_en_t1;
always @(posedge clk) begin
    if(rst) begin
        yolo_layer_en_t0 <= 0;
        yolo_layer_en_t1 <= 0;
    end
    else begin
        yolo_layer_en_t0 <= yolo_layer_en;
        yolo_layer_en_t1 <= yolo_layer_en_t0;
    end
end

wire yolo_layer_en_upedge;
assign yolo_layer_en_upedge = ~yolo_layer_en_t1 & yolo_layer_en_t0;

//产生yolo层控制信号
reg  yolo_en;
reg  trans_finish;
always @(posedge clk) begin
    if(rst || yolo_layer_finish) 
        yolo_en <= 0;
    else if(yolo_layer_en_upedge) 
        yolo_en <= 1;
end

always @(posedge clk) begin
    if(rst || yolo_layer_finish) 
        trans_finish <= 0;
    // else if(yolo_en && dma_wbusy_down && (anchor_sel_t == 2'd3) && (trans_cnt == 4'd11))
    else if(yolo_en && dma_wbusy_down && (anchor_sel_t == 2'd3) && (trans_cnt == 4'd3))
        trans_finish = 1;
    else
        trans_finish = 0;
end


//trans_finish延时五个周期，产生mux_finish
wire mux_finish;
reg [4:0] mux_finish_t;
always @(posedge clk) begin
    if(rst) 
        mux_finish_t <= 0;
    else 
        mux_finish_t <= {mux_finish_t[3:0],trans_finish};
end
assign mux_finish = mux_finish_t[4];


//mux_finish延时32个周期，产生sigmoid_finish
wire sigmoid_finish;
reg [31:0] sigmoid_finish_t;
always @(posedge clk) begin
    if(rst)
        sigmoid_finish_t <= 0;
    else
        sigmoid_finish_t <= {sigmoid_finish_t[30:0],mux_finish};
end
assign sigmoid_finish = sigmoid_finish_t[31];


//产生anchor_sel range  1,2,3   tranas_cnt = 0 - 10
reg [1:0] anchor_sel_t;
reg [3:0] trans_cnt;
always @(posedge clk) begin
    if(rst || yolo_layer_finish) begin
        anchor_sel_t <= 0;
        trans_cnt <= 0;
    end
    else if(yolo_en && dma_wbusy_up) begin
        if(trans_cnt == 3 || trans_cnt == 0) begin
            trans_cnt <= 1;
            anchor_sel_t <= anchor_sel_t + 1;
        end
        else
            trans_cnt <= trans_cnt + 1;
    end   
end

//行列计数
wire   dataIn_valid;
assign dataIn_valid = dma_wvalid & yolo_en;
reg [3:0] i_cnt, j_cnt;   //i_cnt -> col    j_cnt -> row
always @(posedge clk) begin
    if(yolo_layer_finish || dma_wbusy_down) begin
        i_cnt <= 0;
        j_cnt <= 0;
    end
    else if(dataIn_valid && (i_cnt == 4'd14)) begin
        i_cnt <= 0;
        if(j_cnt == 4'd9)
            j_cnt = 0;
        else
            j_cnt <= j_cnt + 1;
    end
    else if(dataIn_valid) begin
        i_cnt <= i_cnt + 1;
        j_cnt <= j_cnt;
    end
end

//根据行列计数器产生比较使能
wire compare_en;
assign compare_en = (i_cnt > 0 && i_cnt < 13) && (j_cnt > 0 && j_cnt < 8);

//比较
wire [7:0] cur_p;
assign cur_p = dma_wdata[39:32];

reg [7:0] p_1;  //概率最大
reg [7:0] p_2;  
reg [7:0] p_3;  
reg [7:0] p_4;  
reg [7:0] p_5;  
reg [31:0] xywh1;
reg [31:0] xywh2;
reg [31:0] xywh3;
reg [31:0] xywh4;
reg [31:0] xywh5;
reg [63:0] pc1;
reg [63:0] pc2;
reg [63:0] pc3;
reg [63:0] pc4;
reg [63:0] pc5;
reg [1:0]  anchor_sel1;
reg [1:0]  anchor_sel2;
reg [1:0]  anchor_sel3;
reg [1:0]  anchor_sel4;
reg [1:0]  anchor_sel5;
reg [3:0]  i_1; //第几行
reg [3:0]  i_2;  
reg [3:0]  i_3;  
reg [3:0]  i_4;  
reg [3:0]  i_5;  
reg [3:0]  j_1; //第几列
reg [3:0]  j_2;  
reg [3:0]  j_3;  
reg [3:0]  j_4;  
reg [3:0]  j_5;   

always @(posedge clk) begin
    if(rst || yolo_layer_finish) begin
        p_1 <= 0;
        p_2 <= 0;
        p_3 <= 0;
        p_4 <= 0;
        p_5 <= 0;
    end
    else if(compare_en && (trans_cnt == 1)) begin
        if(cur_p > p_1 ) begin
            p_1 <= cur_p;
            p_2 <= p_1;
            p_3 <= p_2;
            p_4 <= p_3;
            p_5 <= p_4;
            xywh1 <= dma_wdata[31:0];
            xywh2 <= xywh1;
            xywh3 <= xywh2;
            xywh4 <= xywh3;
            xywh5 <= xywh4;
            pc1 <= {dma_wdata[63:40],40'd0};
            pc2 <= pc1;
            pc3 <= pc2;
            pc4 <= pc3;
            pc5 <= pc4;
            anchor_sel1 <= anchor_sel_t;
            anchor_sel2 <= anchor_sel1;
            anchor_sel3 <= anchor_sel2;
            anchor_sel4 <= anchor_sel3;
            anchor_sel5 <= anchor_sel4;
            i_1 <= i_cnt;
            i_2 <= i_1;
            i_3 <= i_2;
            i_4 <= i_3;
            i_5 <= i_4;
            j_1 <= j_cnt;
            j_2 <= j_1;
            j_3 <= j_2;
            j_4 <= j_3;
            j_5 <= j_4;
        end
        else if(cur_p > p_2 ) begin
            p_2 <= cur_p;
            p_3 <= p_2;
            p_4 <= p_3;
            p_5 <= p_4;
            xywh2 <= dma_wdata[31:0];
            xywh3 <= xywh2;
            xywh4 <= xywh3;
            xywh5 <= xywh4;
            pc2 <= {dma_wdata[63:40],40'd0};
            pc3 <= pc2;
            pc4 <= pc3;
            pc5 <= pc4;
            anchor_sel2 <= anchor_sel_t;
            anchor_sel3 <= anchor_sel2;
            anchor_sel4 <= anchor_sel3;
            anchor_sel5 <= anchor_sel4;
            i_2 <= i_cnt;
            i_3 <= i_2;
            i_4 <= i_3;
            i_5 <= i_4;
            j_2 <= j_cnt;
            j_3 <= j_2;
            j_4 <= j_3;
            j_5 <= j_4;
        end
        else if(cur_p > p_3 ) begin
            p_3 <= cur_p;
            p_4 <= p_3;
            p_5 <= p_4;
            xywh3 <= dma_wdata[31:0];
            xywh4 <= xywh3;
            xywh5 <= xywh4;
            pc3 <= {dma_wdata[63:40],40'd0};
            pc4 <= pc3;
            pc5 <= pc4;
            anchor_sel3 <= anchor_sel_t;
            anchor_sel4 <= anchor_sel3;
            anchor_sel5 <= anchor_sel4;
            i_3 <= i_cnt;
            i_4 <= i_3;
            i_5 <= i_4;
            j_3 <= j_cnt;
            j_4 <= j_3;
            j_5 <= j_4;
        end
        else if(cur_p > p_4 ) begin
            p_4 <= cur_p;
            p_5 <= p_4;
            xywh4 <= dma_wdata[31:0];
            xywh5 <= xywh4;
            pc4 <= {dma_wdata[63:40],40'd0};
            pc5 <= pc4;
            anchor_sel4 <= anchor_sel_t;
            anchor_sel5 <= anchor_sel4;
            i_4 <= i_cnt;
            i_5 <= i_4;
            j_4 <= j_cnt;
            j_5 <= j_4;
        end
        else if(cur_p > p_5 ) begin
            p_5 <= cur_p;
            xywh5 <= dma_wdata[31:0];
            pc5 <= {dma_wdata[63:40],40'd0};
            anchor_sel5 <= anchor_sel_t;
            i_5 <= i_cnt;
            j_5 <= j_cnt;
        end
    end
    else if(compare_en) begin
        if(i_1 == i_cnt && j_1 == j_cnt)
            // if(trans_cnt == 4)
            //     pc1 <= {56'd0,dma_wdata[7:0]};
            // else
                pc1 <= dma_wdata;
        if(i_2 == i_cnt && j_2 == j_cnt)
            // if(trans_cnt == 4)
            //     pc2 <= {56'd0,dma_wdata[7:0]};
            // else
                pc2 <= dma_wdata;
        if(i_3 == i_cnt && j_3 == j_cnt)
            // if(trans_cnt == 4)
            //     pc3 <= {56'd0,dma_wdata[7:0]};
            // else
                pc3 <= dma_wdata;
        if(i_4 == i_cnt && j_4 == j_cnt)
            // if(trans_cnt == 4)
            //     pc4 <= {56'd0,dma_wdata[7:0]};
            // else
                pc4 <= dma_wdata;
        if(i_5 == i_cnt && j_5 == j_cnt)
            // if(trans_cnt == 4)
            //     pc5 <= {56'd0,dma_wdata[7:0]};
            // else
                pc5 <= dma_wdata;
    end
    else if(!dma_wbusy)begin
        pc1 <= 0;
        pc2 <= 0;
        pc3 <= 0;
        pc4 <= 0;
        pc5 <= 0;
    end
end

wire [7:0] cmax8_value_1;
wire [2:0] cmax8_index_1;
wire [7:0] cmax8_value_2;
wire [2:0] cmax8_index_2;
wire [7:0] cmax8_value_3;
wire [2:0] cmax8_index_3;
wire [7:0] cmax8_value_4;
wire [2:0] cmax8_index_4;
wire [7:0] cmax8_value_5;
wire [2:0] cmax8_index_5;

cal_comparator_1x8x5 u_cal_comparator_1x8x5(
    .clk               ( clk           ),
    .rst               ( rst           ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .pc1               ( pc1           ),
    .pc2               ( pc2           ),
    .pc3               ( pc3           ),
    .pc4               ( pc4           ),
    .pc5               ( pc5           ),
    .cmax8_value_1     ( cmax8_value_1 ),
    .cmax8_value_2     ( cmax8_value_2 ),
    .cmax8_value_3     ( cmax8_value_3 ),
    .cmax8_value_4     ( cmax8_value_4 ),
    .cmax8_value_5     ( cmax8_value_5 ),
    .cmax8_index_1     ( cmax8_index_1 ),
    .cmax8_index_2     ( cmax8_index_2 ),
    .cmax8_index_3     ( cmax8_index_3 ),
    .cmax8_index_4     ( cmax8_index_4 ),
    .cmax8_index_5     ( cmax8_index_5  )
);


//选择类别
wire [6:0]  class_sel1;
wire [6:0]  class_sel2;
wire [6:0]  class_sel3;
wire [6:0]  class_sel4;
wire [6:0]  class_sel5;
wire [7:0]  class_1;
wire [7:0]  class_2;
wire [7:0]  class_3;
wire [7:0]  class_4;
wire [7:0]  class_5;
cal_class_x5 u_cal_class_x5(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .en                ( dma_wbusy_down && yolo_en),
    .trans_cnt         ( trans_cnt         ),
    .anchor_sel_t      ( anchor_sel_t      ),
    .cmax8_value_1     ( cmax8_value_1     ),
    .cmax8_value_2     ( cmax8_value_2     ),
    .cmax8_value_3     ( cmax8_value_3     ),
    .cmax8_value_4     ( cmax8_value_4     ),
    .cmax8_value_5     ( cmax8_value_5     ),
    .cmax8_index_1     ( cmax8_index_1     ),
    .cmax8_index_2     ( cmax8_index_2     ),
    .cmax8_index_3     ( cmax8_index_3     ),
    .cmax8_index_4     ( cmax8_index_4     ),
    .cmax8_index_5     ( cmax8_index_5     ),
    .cmax1             ( class_1           ),
    .cmax2             ( class_2           ),
    .cmax3             ( class_3           ),
    .cmax4             ( class_4           ),
    .cmax5             ( class_5           ),
    .cindex1           ( class_sel1        ),
    .cindex2           ( class_sel2        ),
    .cindex3           ( class_sel3        ),
    .cindex4           ( class_sel4        ),
    .cindex5           ( class_sel5        )
);

//产生sigmoid使能信号
reg sigmoid_en;
always @(posedge clk) begin
    if(rst) 
        sigmoid_en <= 0;
    else if(mux_finish)
        sigmoid_en <= 1;
    else if(sigmoid_finish)
        sigmoid_en <= 0;
end

//计算xywhcp的sigmoid值
//五个目标共30个周期
reg [4:0]  sigmoid_cnt;
reg [7:0]  addr;
always @(posedge clk) begin
    if(sigmoid_en) 
        sigmoid_cnt <= sigmoid_cnt + 1;
    else 
        sigmoid_cnt <= 0;
end

always @(posedge clk) begin
    case(sigmoid_cnt)
        5'd0: addr <= xywh1[7:0];   //x
        5'd1: addr <= xywh1[15:8];  //y
        5'd2: addr <= xywh1[23:16]; //w
        5'd3: addr <= xywh1[31:24]; //h
        5'd4: addr <= p_1;          //p
        5'd5: addr <= class_1;
        5'd6: addr <= xywh2[7:0];
        5'd7: addr <= xywh2[15:8];
        5'd8: addr <= xywh2[23:16];
        5'd9: addr <= xywh2[31:24];
        5'd10: addr <= p_2;
        5'd11: addr <= class_2;
        5'd12: addr <= xywh3[7:0];
        5'd13: addr <= xywh3[15:8];
        5'd14: addr <= xywh3[23:16];
        5'd15: addr <= xywh3[31:24];
        5'd16: addr <= p_3;
        5'd17: addr <= class_3;
        5'd18: addr <= xywh4[7:0];
        5'd19: addr <= xywh4[15:8];
        5'd20: addr <= xywh4[23:16];
        5'd21: addr <= xywh4[31:24];
        5'd22: addr <= p_4;
        5'd23: addr <= class_4;
        5'd24: addr <= xywh5[7:0];
        5'd25: addr <= xywh5[15:8];
        5'd26: addr <= xywh5[23:16];
        5'd27: addr <= xywh5[31:24];
        5'd28: addr <= p_5;
        5'd29: addr <= class_5;
        default:addr <= 0;
    endcase 
end

wire [13:0] data_frac;   //2^14 = 16384
wire [3:0]  data_exp;    //2^4  = 16
com_sigmoid u_com_sigmoid(
    .clk       ( clk         ),
    .addr      ( addr        ),
    .en        ( 1'b1        ),
    .data_frac ( data_frac   ),
    .data_exp  ( data_exp    )
);

reg [17:0] x_target1, y_target1, w_target1, h_target1, p_target1, c_target1;
reg [17:0] x_target2, y_target2, w_target2, h_target2, p_target2, c_target2;
reg [17:0] x_target3, y_target3, w_target3, h_target3, p_target3, c_target3;
reg [17:0] x_target4, y_target4, w_target4, h_target4, p_target4, c_target4;
reg [17:0] x_target5, y_target5, w_target5, h_target5, p_target5, c_target5;

reg [4:0]  sigmoid_cnt_t0;
reg [4:0]  sigmoid_cnt_t1;
always @(posedge clk) begin
    sigmoid_cnt_t0 <= sigmoid_cnt;
    sigmoid_cnt_t1 <= sigmoid_cnt_t0;
    case(sigmoid_cnt_t1)
        5'd0:  x_target1 <= {data_exp,data_frac};
        5'd1:  y_target1 <= {data_exp,data_frac};
        5'd2:  w_target1 <= {data_exp,data_frac};
        5'd3:  h_target1 <= {data_exp,data_frac};
        5'd4:  p_target1 <= {data_exp,data_frac};
        5'd5:  c_target1 <= {data_exp,data_frac};

        5'd6:  x_target2 <= {data_exp,data_frac};
        5'd7:  y_target2 <= {data_exp,data_frac};
        5'd8:  w_target2 <= {data_exp,data_frac};
        5'd9:  h_target2 <= {data_exp,data_frac};
        5'd10:  p_target2 <= {data_exp,data_frac};
        5'd11:  c_target2 <= {data_exp,data_frac};

        5'd12:  x_target3 <= {data_exp,data_frac};
        5'd13:  y_target3 <= {data_exp,data_frac};
        5'd14:  w_target3 <= {data_exp,data_frac};
        5'd15:  h_target3 <= {data_exp,data_frac};
        5'd16:  p_target3 <= {data_exp,data_frac};
        5'd17:  c_target3 <= {data_exp,data_frac};

        5'd18:  x_target4 <= {data_exp,data_frac};
        5'd19:  y_target4 <= {data_exp,data_frac};
        5'd20:  w_target4 <= {data_exp,data_frac};
        5'd21:  h_target4 <= {data_exp,data_frac};
        5'd22:  p_target4 <= {data_exp,data_frac};
        5'd23:  c_target4 <= {data_exp,data_frac};
        
        5'd24:  x_target5 <= {data_exp,data_frac};
        5'd25:  y_target5 <= {data_exp,data_frac};
        5'd26:  w_target5 <= {data_exp,data_frac};
        5'd27:  h_target5 <= {data_exp,data_frac};
        5'd28:  p_target5 <= {data_exp,data_frac};
        5'd29:  c_target5 <= {data_exp,data_frac};
        default :;
    endcase
end

wire [31:0] reg0_target1_t;
wire [31:0] reg1_target1_t;
wire [31:0] reg2_target1_t;
wire [31:0] reg3_target1_t;
wire [31:0] reg0_target2_t;
wire [31:0] reg1_target2_t;
wire [31:0] reg2_target2_t;
wire [31:0] reg3_target2_t;
wire [31:0] reg0_target3_t;
wire [31:0] reg1_target3_t;
wire [31:0] reg2_target3_t;
wire [31:0] reg3_target3_t;
wire [31:0] reg0_target4_t;
wire [31:0] reg1_target4_t;
wire [31:0] reg2_target4_t;
wire [31:0] reg3_target4_t;
wire [31:0] reg0_target5_t;
wire [31:0] reg1_target5_t;
wire [31:0] reg2_target5_t;
wire [31:0] reg3_target5_t;
wire [31:0] reg_anchor_sel_t;

assign reg0_target1_t = {x_target1[13:0],y_target1[13:0],x_target1[17:14]};
assign reg1_target1_t = {w_target1[13:0],h_target1[13:0],y_target1[17:14]};
assign reg2_target1_t = {p_target1[13:0],c_target1[13:0],4'd0};
assign reg3_target1_t = {w_target1[17:14], h_target1[17:14], p_target1[17:14], c_target1[17:14],
                       i_1, j_1, 1'b0, class_sel1};

assign reg0_target2_t = {x_target2[13:0],y_target2[13:0],x_target2[17:14]};
assign reg1_target2_t = {w_target2[13:0],h_target2[13:0],y_target2[17:14]};
assign reg2_target2_t = {p_target2[13:0],c_target2[13:0],4'd0};
assign reg3_target2_t = {w_target2[17:14], h_target2[17:14], p_target2[17:14], c_target2[17:14],
                       i_2, j_2, 1'b0, class_sel2};

assign reg0_target3_t = {x_target3[13:0],y_target3[13:0],x_target3[17:14]};
assign reg1_target3_t = {w_target3[13:0],h_target3[13:0],y_target3[17:14]};
assign reg2_target3_t = {p_target3[13:0],c_target3[13:0],4'd0};
assign reg3_target3_t = {w_target3[17:14], h_target3[17:14], p_target3[17:14], c_target3[17:14],
                       i_3, j_3, 1'b0, class_sel3};

assign reg0_target4_t = {x_target4[13:0],y_target4[13:0],x_target4[17:14]};
assign reg1_target4_t = {w_target4[13:0],h_target4[13:0],y_target4[17:14]};
assign reg2_target4_t = {p_target4[13:0],c_target4[13:0],4'd0};
assign reg3_target4_t = {w_target4[17:14], h_target4[17:14], p_target4[17:14], c_target4[17:14],
                       i_4, j_4, 1'b0, class_sel4};

assign reg0_target5_t = {x_target5[13:0],y_target5[13:0],x_target5[17:14]};
assign reg1_target5_t = {w_target5[13:0],h_target5[13:0],y_target5[17:14]};
assign reg2_target5_t = {p_target5[13:0],c_target5[13:0],4'd0};
assign reg3_target5_t = {w_target5[17:14], h_target5[17:14], p_target5[17:14], c_target5[17:14],
                       i_5, j_5, 1'b0, class_sel5};

assign reg_anchor_sel_t = {22'd0,anchor_sel5,anchor_sel4,anchor_sel3,anchor_sel2,anchor_sel1};


//sigmoid_finish 延时5个周期
reg [9:0] sigmoid_finish_delay10;
always @(posedge clk) begin
    if(rst) 
        sigmoid_finish_delay10 <= 0;
    else 
        sigmoid_finish_delay10 <= {sigmoid_finish_delay10[8:0],sigmoid_finish};
end

//产生更新使能
wire target_reg_en;
assign target_reg_en = sigmoid_finish_delay10[6];
reg [31:0] reg0_target1;
reg [31:0] reg1_target1;
reg [31:0] reg2_target1;
reg [31:0] reg3_target1;
reg [31:0] reg0_target2;
reg [31:0] reg1_target2;
reg [31:0] reg2_target2;
reg [31:0] reg3_target2;
reg [31:0] reg0_target3;
reg [31:0] reg1_target3;
reg [31:0] reg2_target3;
reg [31:0] reg3_target3;
reg [31:0] reg0_target4;
reg [31:0] reg1_target4;
reg [31:0] reg2_target4;
reg [31:0] reg3_target4;
reg [31:0] reg0_target5;
reg [31:0] reg1_target5;
reg [31:0] reg2_target5;
reg [31:0] reg3_target5;
reg [31:0] reg_anchor_sel;
always @(posedge clk) begin
    if(rst) begin
        reg0_target1 <= 0;
        reg1_target1 <= 0;
        reg2_target1 <= 0;
        reg3_target1 <= 0;
        reg0_target2 <= 0;
        reg1_target2 <= 0;
        reg2_target2 <= 0;
        reg3_target2 <= 0;
        reg0_target3 <= 0;
        reg1_target3 <= 0;
        reg2_target3 <= 0;
        reg3_target3 <= 0;
        reg0_target4 <= 0;
        reg1_target4 <= 0;
        reg2_target4 <= 0;
        reg3_target4 <= 0;
        reg0_target5 <= 0;
        reg1_target5 <= 0;
        reg2_target5 <= 0;
        reg3_target5 <= 0;
    end
    else if(target_reg_en) begin
        reg0_target1 <= reg0_target1_t;
        reg1_target1 <= reg1_target1_t;
        reg2_target1 <= reg2_target1_t;
        reg3_target1 <= reg3_target1_t;
        reg0_target2 <= reg0_target2_t;
        reg1_target2 <= reg1_target2_t;
        reg2_target2 <= reg2_target2_t;
        reg3_target2 <= reg3_target2_t;
        reg0_target3 <= reg0_target3_t;
        reg1_target3 <= reg1_target3_t;
        reg2_target3 <= reg2_target3_t;
        reg3_target3 <= reg3_target3_t;
        reg0_target4 <= reg0_target4_t;
        reg1_target4 <= reg1_target4_t;
        reg2_target4 <= reg2_target4_t;
        reg3_target4 <= reg3_target4_t;
        reg0_target5 <= reg0_target5_t;
        reg1_target5 <= reg1_target5_t;
        reg2_target5 <= reg2_target5_t;
        reg3_target5 <= reg3_target5_t;
        reg_anchor_sel <= reg_anchor_sel_t;
    end
end

//target_reg_en延时两个周期
reg target_reg_en_t0;
reg target_reg_en_t1;
always @(posedge clk) begin
    if(rst) begin
        target_reg_en_t0 <= 0;
        target_reg_en_t1 <= 0;
    end
    else begin
        target_reg_en_t0 <= target_reg_en;
        target_reg_en_t1 <= target_reg_en_t0;
    end
end

//产生yolo_clr的上升沿
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

reg [5:0]  yolo_addr;
reg        mem_load_en;
always @(posedge clk) begin
    if(rst) begin
        yolo_addr <= 0;
        mem_load_en <= 0;
    end
    else if(target_reg_en_t1) begin
        mem_load_en <= 1;
    end
    else if(mem_load_en) begin
        if(yolo_addr == 20) begin
            yolo_addr <= 0;
            mem_load_en <= 0;
        end
        else
            yolo_addr <= yolo_addr + 1;
    end
end

//产生yolo_layer_finish
always @(posedge clk) begin
    if(rst || yolo_clr_up) 
        yolo_layer_finish <= 0;
    else if(mem_load_en == 1 && yolo_addr == 20) 
        yolo_layer_finish <= 1;
end

reg [31:0] yolo_data;
always @(*) begin
    case(yolo_addr)
        6'd0 : yolo_data <= reg0_target1;
        6'd1 : yolo_data <= reg1_target1;
        6'd2 : yolo_data <= reg2_target1;
        6'd3 : yolo_data <= reg3_target1;
        6'd4 : yolo_data <= reg0_target2;
        6'd5 : yolo_data <= reg1_target2;
        6'd6 : yolo_data <= reg2_target2;
        6'd7 : yolo_data <= reg3_target2;
        6'd8 : yolo_data <= reg0_target3;
        6'd9 : yolo_data <= reg1_target3;
        6'd10: yolo_data <= reg2_target3;
        6'd11: yolo_data <= reg3_target3;
        6'd12: yolo_data <= reg0_target4;
        6'd13: yolo_data <= reg1_target4;
        6'd14: yolo_data <= reg2_target4;
        6'd15: yolo_data <= reg3_target4;
        6'd16: yolo_data <= reg0_target5;
        6'd17: yolo_data <= reg1_target5;
        6'd18: yolo_data <= reg2_target5;
        6'd19: yolo_data <= reg3_target5;
        6'd20: yolo_data <= reg_anchor_sel;
        default: yolo_data <= 0;
    endcase
end


(*ram_style="block"*)reg [31:0] sigmoid_mem[0:20];
always @(posedge clk) begin
    if(mem_load_en) begin
        sigmoid_mem[yolo_addr] <= yolo_data;
    end
end

always @(posedge e203_clk or negedge e203_rst_n) begin
    if(!e203_rst_n)
        send_data <= 0;
    else
        send_data <= sigmoid_mem[send_addr];
end

reg [31:0] yolo_finish_0_cnt;
reg [31:0] yolo_finish_1_cnt;
always @(posedge clk ) begin
    if(rst)
        yolo_finish_0_cnt <= 0;
    else if(yolo_layer_finish == 0)
        yolo_finish_0_cnt <= yolo_finish_0_cnt + 1;
    else 
        yolo_finish_0_cnt <= 0;
end

always @(posedge clk ) begin
    if(rst)
        yolo_finish_1_cnt <= 0;
    else if(yolo_layer_finish == 1)
        yolo_finish_1_cnt <= yolo_finish_1_cnt + 1;
    else 
        yolo_finish_1_cnt <= 0;
end

ila_0 u_ila(
    .clk   (clk),
    .probe0 ({yolo_layer_finish,yolo_layer_en_upedge,target_reg_en,yolo_clr_up,yolo_clr,yolo_layer_en,yolo_en,sigmoid_finish,trans_finish,mux_finish,sigmoid_cnt,addr,sigmoid_en}),
    .probe1 ({dma_wbusy,i_cnt,j_cnt,compare_en,mem_load_en,yolo_addr,yolo_data,anchor_sel_t,dma_wbusy_down,dma_wbusy_up,dma_wvalid}),
    .probe2 ({yolo_finish_1_cnt,yolo_finish_0_cnt}),
    .probe3 ({reg0_target1,reg1_target1})
);

endmodule