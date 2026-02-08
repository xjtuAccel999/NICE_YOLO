module rectangle_make#(
    parameter  H_ACTIVE = 1920, //显示区域宽度                              
    parameter  V_ACTIVE = 1080,  //显示区域高度
    parameter  RECT_COLOR1 = 24'h00ff00,  //绿色  bgr
    parameter  RECT_COLOR2 = 24'hff0000,  //红色  bgr
    parameter  RECT_COLOR3 = 24'h0000ff,  //蓝色  bgr
    parameter  RECT_COLOR4 = 24'hffff00,  //绿色  bgr
    parameter  RECT_COLOR5 = 24'h00ffff,  //红色  bgr

    parameter  H_OUTPUT = 418,
    parameter  V_OUTPUT = 258,
    parameter  H_LEFT = (H_ACTIVE - 4*H_OUTPUT)/2,//124
    parameter  H_RIGHT = H_ACTIVE - H_LEFT,//1796
    parameter  V_LEFT = (V_ACTIVE - 4*V_OUTPUT)/2,//24
    parameter  V_RIGHT = V_ACTIVE - V_LEFT,//1056
    parameter  H_OFFSET = H_LEFT/4, //31
    parameter  V_OFFSET = V_LEFT/4  //6
)
`include "rgb_color_para.v"
(
    input i_clk,
    input i_rst_n,

    input i_hsyn,
    input i_vsyn,
    input i_de,
    input [23:0] i_data,
    
    input i_rect_en,

    input [31:0] reg0_rect1,
    input [31:0] reg1_rect1,
    input [31:0] reg0_rect2,
    input [31:0] reg1_rect2,
    input [31:0] reg0_rect3,
    input [31:0] reg1_rect3,
    input [31:0] reg0_rect4,
    input [31:0] reg1_rect4,
    input [31:0] reg0_rect5,
    input [31:0] reg1_rect5,

    output reg o_hsyn,
    output reg o_vsyn,
    output reg o_de,
    output reg [23:0] o_data
);

reg i_rect_en_t0;
reg i_rect_en_t1;
always @(posedge i_clk or negedge i_rst_n) begin 
    if(!i_rst_n) begin 
        i_rect_en_t0 <= 0;
        i_rect_en_t1 <= 0;
    end
    else begin 
        i_rect_en_t0 <= i_rect_en;
        i_rect_en_t1 <= i_rect_en_t0;
    end
end
wire i_rect_en_up_edge;
assign i_rect_en_up_edge = ~i_rect_en_t1 & i_rect_en_t0;

reg  [10:0] 	    h_cnt;
reg  [10:0] 	    v_cnt;

reg [8:0] x1,x2,x3,x4,x5;
reg [8:0] y1,y2,y3,y4,y5;
reg [8:0] w1,w2,w3,w4,w5;
reg [8:0] h1,h2,h3,h4,h5;
reg [4:0] c1,c2,c3,c4,c5;
reg [2:0] id1,id2,id3,id4,id5;
reg [2:0] num;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        {x1,x2,x3,x4,x5} <= 0;
        {y1,y2,y3,y4,y5} <= 0;
        {w1,w2,w3,w4,w5} <= 0;
        {h1,h2,h3,h4,h5} <= 0;
        {c1,c2,c3,c4,c5} <= 0;
        {id1,id2,id3,id4,id5} <= 0;
        num <= 0;  
    end
    else if(i_rect_en_up_edge) begin
        {x1,x2,x3,x4,x5} <= {reg0_rect1[8:0],  reg0_rect2[8:0],  reg0_rect3[8:0],  reg0_rect4[8:0],  reg0_rect5[8:0]};
        {y1,y2,y3,y4,y5} <= {reg0_rect1[17:9], reg0_rect2[17:9], reg0_rect3[17:9], reg0_rect4[17:9], reg0_rect5[17:9]};
        {w1,w2,w3,w4,w5} <= {reg0_rect1[26:18],reg0_rect2[26:18],reg0_rect3[26:18],reg0_rect4[26:18],reg0_rect5[26:18]};
        {h1,h2,h3,h4,h5} <= {reg1_rect1[8:0],  reg1_rect2[8:0],  reg1_rect3[8:0],  reg1_rect4[8:0],  reg1_rect5[8:0]};
        {c1,c2,c3,c4,c5} <= {reg1_rect1[13:9], reg1_rect2[13:9], reg1_rect3[13:9], reg1_rect4[13:9], reg1_rect5[13:9]};
        {id1,id2,id3,id4,id5} <= {reg1_rect1[19:17],reg1_rect2[19:17],reg1_rect3[19:17],reg1_rect4[19:17],reg1_rect5[19:17]};
        num <= reg1_rect1[16:14];  
    end
    // else begin
        // {x1,x2,x3,x4,x5} <= {9'd400,9'd300,9'd200,9'd100,9'd50};
        // {y1,y2,y3,y4,y5} <= {9'd200,9'd100,9'd200,9'd250,9'd50};
        // {w1,w2,w3,w4,w5} <= {9'd200,9'd30,9'd70,9'd50,9'd50};
        // {h1,h2,h3,h4,h5} <= {9'd50,9'd80,9'd70,9'd100,9'd50};
        // {c1,c2,c3,c4,c5} <= {4'd0,4'd1,4'd2,4'd0,4'd1};
        // {id1,id2,id3,id4,id5} <= {4'd0,4'd1,4'd2,4'd3,4'd4};
        // num <= 4'd4;  
    // end
end

//计算临界点
reg [10:0] xleft1,xleft2,xleft3,xleft4,xleft5;
reg [10:0] ytop1,ytop2,ytop3,ytop4,ytop5;
reg [10:0] xright1,xright2,xright3,xright4,xright5;
reg [10:0] ydown1,ydown2,ydown3,ydown4,ydown5;
always@(posedge i_clk) begin
    xleft1  <= (x1-w1+H_OFFSET)<<2;
    xleft2  <= (x2-w2+H_OFFSET)<<2;
    xleft3  <= (x3-w3+H_OFFSET)<<2;
    xleft4  <= (x4-w4+H_OFFSET)<<2;
    xleft5  <= (x5-w5+H_OFFSET)<<2;
    xright1 <= (x1+w1+H_OFFSET)<<2;
    xright2 <= (x2+w2+H_OFFSET)<<2;
    xright3 <= (x3+w3+H_OFFSET)<<2;
    xright4 <= (x4+w4+H_OFFSET)<<2;
    xright5 <= (x5+w5+H_OFFSET)<<2;
    ytop1   <= (y1-h1+V_OFFSET)<<2;
    ytop2   <= (y2-h2+V_OFFSET)<<2;
    ytop3   <= (y3-h3+V_OFFSET)<<2;
    ytop4   <= (y4-h4+V_OFFSET)<<2;
    ytop5   <= (y5-h5+V_OFFSET)<<2;
    ydown1  <= (y1+h1+V_OFFSET)<<2;
    ydown2  <= (y2+h2+V_OFFSET)<<2;
    ydown3  <= (y3+h3+V_OFFSET)<<2;
    ydown4  <= (y4+h4+V_OFFSET)<<2;
    ydown5  <= (y5+h5+V_OFFSET)<<2;
end

//显示区域行计数
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) 
        h_cnt <= 11'd0;
    else if(i_de) begin
		if(h_cnt == H_ACTIVE - 1'b1)
			h_cnt <= 11'd0;
		else 
			h_cnt <= h_cnt + 11'd1;
    end
end

//显示区域场计数
always@(posedge i_clk or negedge i_rst_n)  begin
    if(!i_rst_n)
        v_cnt <= 11'd0;
    else if(h_cnt == H_ACTIVE - 1'b1) begin
		if(v_cnt == V_ACTIVE - 1'b1)
			v_cnt <= 11'd0;
		else 
			v_cnt <= v_cnt + 11'd1;
    end
end

//绘制矩形
reg [23:0] o_data_t1;
reg [23:0] o_data_t2;
reg [23:0] o_data_t3;
reg [23:0] o_data_t4;
reg [23:0] o_data_t5;
reg o_valid_t1;
reg o_valid_t2;
reg o_valid_t3;
reg o_valid_t4;
reg o_valid_t5;

//第一个目标
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_t1 <= 0;
        o_valid_t1 <= 0;
    end
    else if(id1 < num) begin
    // else if(num > 0) begin
        if(((h_cnt == xleft1 || h_cnt == xright1 ) && v_cnt >= ytop1 && v_cnt <= ydown1)||
			((v_cnt == ytop1 || v_cnt == ydown1 ) && h_cnt >= xleft1 && h_cnt <= xright1 ||(char_area_valid_0_t & io_pixel_t) )) begin
            o_valid_t1 <= 1;
            // o_data_t1 <= RECT_COLOR1;
            case(c1)
                5'd0 : o_data_t1 <= `RGB_COLOR0 ;
                5'd1 : o_data_t1 <= `RGB_COLOR1 ;
                5'd2 : o_data_t1 <= `RGB_COLOR2 ;
                5'd3 : o_data_t1 <= `RGB_COLOR3 ;
                5'd4 : o_data_t1 <= `RGB_COLOR4 ;
                5'd5 : o_data_t1 <= `RGB_COLOR5 ;
                5'd6 : o_data_t1 <= `RGB_COLOR6 ;
                5'd7 : o_data_t1 <= `RGB_COLOR7 ;
                5'd8 : o_data_t1 <= `RGB_COLOR8 ;
                5'd9 : o_data_t1 <= `RGB_COLOR9 ;
                5'd10: o_data_t1 <= `RGB_COLOR10;
                5'd11: o_data_t1 <= `RGB_COLOR11;
                5'd12: o_data_t1 <= `RGB_COLOR12;
                5'd13: o_data_t1 <= `RGB_COLOR13;
                5'd14: o_data_t1 <= `RGB_COLOR14;
                5'd15: o_data_t1 <= `RGB_COLOR15;
                5'd16: o_data_t1 <= `RGB_COLOR16;
                5'd17: o_data_t1 <= `RGB_COLOR17;
                5'd18: o_data_t1 <= `RGB_COLOR18;
                5'd19: o_data_t1 <= `RGB_COLOR19;
                default: o_data_t1 <= 0;
            endcase
        end
        else begin
            o_data_t1 <= 0;
            o_valid_t1 <= 0;
        end
    end
    else begin
        o_data_t1 <= 0;
        o_valid_t1 <= 0;
    end
end

//第二个目标
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_t2 <= 0;
        o_valid_t2 <= 0;
    end
    else if(id2 < num) begin
    // else if(num > 1) begin
        if(((h_cnt == xleft2 || h_cnt == xright2 ) && v_cnt >= ytop2 && v_cnt <= ydown2)||
			((v_cnt == ytop2 || v_cnt == ydown2 ) && h_cnt >= xleft2 && h_cnt <= xright2 ||(char_area_valid_1_t & io_pixel_t))) begin
            o_valid_t2 <= 1;
            // o_data_t2 <= RECT_COLOR2;
            case(c2)
                5'd0 : o_data_t2 <= `RGB_COLOR0 ;
                5'd1 : o_data_t2 <= `RGB_COLOR1 ;
                5'd2 : o_data_t2 <= `RGB_COLOR2 ;
                5'd3 : o_data_t2 <= `RGB_COLOR3 ;
                5'd4 : o_data_t2 <= `RGB_COLOR4 ;
                5'd5 : o_data_t2 <= `RGB_COLOR5 ;
                5'd6 : o_data_t2 <= `RGB_COLOR6 ;
                5'd7 : o_data_t2 <= `RGB_COLOR7 ;
                5'd8 : o_data_t2 <= `RGB_COLOR8 ;
                5'd9 : o_data_t2 <= `RGB_COLOR9 ;
                5'd10: o_data_t2 <= `RGB_COLOR10;
                5'd11: o_data_t2 <= `RGB_COLOR11;
                5'd12: o_data_t2 <= `RGB_COLOR12;
                5'd13: o_data_t2 <= `RGB_COLOR13;
                5'd14: o_data_t2 <= `RGB_COLOR14;
                5'd15: o_data_t2 <= `RGB_COLOR15;
                5'd16: o_data_t2 <= `RGB_COLOR16;
                5'd17: o_data_t2 <= `RGB_COLOR17;
                5'd18: o_data_t2 <= `RGB_COLOR18;
                5'd19: o_data_t2 <= `RGB_COLOR19;
                default: o_data_t2 <= 0;
            endcase
        end
        else begin
            o_data_t2 <= 0;
            o_valid_t2 <= 0;
        end
    end
    else begin
        o_data_t2 <= 0;
        o_valid_t2 <= 0;
    end
end

//第三个目标
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_t3 <= 0;
        o_valid_t3 <= 0;
    end
    else if(id3 < num) begin
    // else if(num > 2) begin
        if(((h_cnt == xleft3 || h_cnt == xright3 ) && v_cnt >= ytop3 && v_cnt <= ydown3)||
			((v_cnt == ytop3 || v_cnt == ydown3 ) && h_cnt >= xleft3 && h_cnt <= xright3 ||(char_area_valid_2_t & io_pixel_t))) begin
            o_valid_t3 <= 1;
            // o_data_t3 <= RECT_COLOR3;
            case(c3)
                5'd0 : o_data_t3 <= `RGB_COLOR0 ;
                5'd1 : o_data_t3 <= `RGB_COLOR1 ;
                5'd2 : o_data_t3 <= `RGB_COLOR2 ;
                5'd3 : o_data_t3 <= `RGB_COLOR3 ;
                5'd4 : o_data_t3 <= `RGB_COLOR4 ;
                5'd5 : o_data_t3 <= `RGB_COLOR5 ;
                5'd6 : o_data_t3 <= `RGB_COLOR6 ;
                5'd7 : o_data_t3 <= `RGB_COLOR7 ;
                5'd8 : o_data_t3 <= `RGB_COLOR8 ;
                5'd9 : o_data_t3 <= `RGB_COLOR9 ;
                5'd10: o_data_t3 <= `RGB_COLOR10;
                5'd11: o_data_t3 <= `RGB_COLOR11;
                5'd12: o_data_t3 <= `RGB_COLOR12;
                5'd13: o_data_t3 <= `RGB_COLOR13;
                5'd14: o_data_t3 <= `RGB_COLOR14;
                5'd15: o_data_t3 <= `RGB_COLOR15;
                5'd16: o_data_t3 <= `RGB_COLOR16;
                5'd17: o_data_t3 <= `RGB_COLOR17;
                5'd18: o_data_t3 <= `RGB_COLOR18;
                5'd19: o_data_t3 <= `RGB_COLOR19;
                default: o_data_t3 <= 0;
            endcase
        end
        else begin
            o_data_t3 <= 0;
            o_valid_t3 <= 0;
        end
    end
    else begin
        o_data_t3 <= 0;
        o_valid_t3 <= 0;
    end
end

//第四个目标
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_t4 <= 0;
        o_valid_t4 <= 0;
    end
    else if(id4 < num) begin
    // else if(num > 3) begin
        if(((h_cnt == xleft4 || h_cnt == xright4 ) && v_cnt >= ytop4 && v_cnt <= ydown4)||
			((v_cnt == ytop4 || v_cnt == ydown4 ) && h_cnt >= xleft4 && h_cnt <= xright4 ||(char_area_valid_3_t & io_pixel_t))) begin
            o_valid_t4 <= 1;
            // o_data_t4 <= RECT_COLOR4;
            case(c4)
                5'd0 : o_data_t4 <= `RGB_COLOR0 ;
                5'd1 : o_data_t4 <= `RGB_COLOR1 ;
                5'd2 : o_data_t4 <= `RGB_COLOR2 ;
                5'd3 : o_data_t4 <= `RGB_COLOR3 ;
                5'd4 : o_data_t4 <= `RGB_COLOR4 ;
                5'd5 : o_data_t4 <= `RGB_COLOR5 ;
                5'd6 : o_data_t4 <= `RGB_COLOR6 ;
                5'd7 : o_data_t4 <= `RGB_COLOR7 ;
                5'd8 : o_data_t4 <= `RGB_COLOR8 ;
                5'd9 : o_data_t4 <= `RGB_COLOR9 ;
                5'd10: o_data_t4 <= `RGB_COLOR10;
                5'd11: o_data_t4 <= `RGB_COLOR11;
                5'd12: o_data_t4 <= `RGB_COLOR12;
                5'd13: o_data_t4 <= `RGB_COLOR13;
                5'd14: o_data_t4 <= `RGB_COLOR14;
                5'd15: o_data_t4 <= `RGB_COLOR15;
                5'd16: o_data_t4 <= `RGB_COLOR16;
                5'd17: o_data_t4 <= `RGB_COLOR17;
                5'd18: o_data_t4 <= `RGB_COLOR18;
                5'd19: o_data_t4 <= `RGB_COLOR19;
                default: o_data_t4 <= 0;
            endcase
        end
        else begin
            o_data_t4 <= 0;
            o_valid_t4 <= 0;
        end
    end
    else begin
        o_data_t4 <= 0;
        o_valid_t4 <= 0;
    end
end

//第五个目标
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_t5 <= 0;
        o_valid_t5 <= 0;
    end
    else if(id5 < num) begin
    // else if(num > 4) begin
        if(((h_cnt == xleft5 || h_cnt == xright5 ) && v_cnt >= ytop5 && v_cnt <= ydown5)||
			((v_cnt == ytop5 || v_cnt == ydown5 ) && h_cnt >= xleft5 && h_cnt <= xright5 ||(char_area_valid_4_t & io_pixel_t))) begin
            o_valid_t5 <= 1;
            // o_data_t5 <= RECT_COLOR5;
            case(c5)
                5'd0 : o_data_t5 <= `RGB_COLOR0 ;
                5'd1 : o_data_t5 <= `RGB_COLOR1 ;
                5'd2 : o_data_t5 <= `RGB_COLOR2 ;
                5'd3 : o_data_t5 <= `RGB_COLOR3 ;
                5'd4 : o_data_t5 <= `RGB_COLOR4 ;
                5'd5 : o_data_t5 <= `RGB_COLOR5 ;
                5'd6 : o_data_t5 <= `RGB_COLOR6 ;
                5'd7 : o_data_t5 <= `RGB_COLOR7 ;
                5'd8 : o_data_t5 <= `RGB_COLOR8 ;
                5'd9 : o_data_t5 <= `RGB_COLOR9 ;
                5'd10: o_data_t5 <= `RGB_COLOR10;
                5'd11: o_data_t5 <= `RGB_COLOR11;
                5'd12: o_data_t5 <= `RGB_COLOR12;
                5'd13: o_data_t5 <= `RGB_COLOR13;
                5'd14: o_data_t5 <= `RGB_COLOR14;
                5'd15: o_data_t5 <= `RGB_COLOR15;
                5'd16: o_data_t5 <= `RGB_COLOR16;
                5'd17: o_data_t5 <= `RGB_COLOR17;
                5'd18: o_data_t5 <= `RGB_COLOR18;
                5'd19: o_data_t5 <= `RGB_COLOR19;
                default: o_data_t5 <= 0;
            endcase
        end
        else begin
            o_data_t5 <= 0;
            o_valid_t5 <= 0;
        end
    end
    else begin
        o_data_t5 <= 0;
        o_valid_t5 <= 0;
    end
end

wire io_pixel;
wire char_area_valid_0;
wire char_area_valid_1;
wire char_area_valid_2;
wire char_area_valid_3;
wire char_area_valid_4;
CharOutput u_CharOutput(
    .clock           ( i_clk           ),
    .reset           ( ~i_rst_n           ),
    .io_h_cnt        ( h_cnt        ),
    .io_v_cnt        ( v_cnt        ),
    .io_class_voc_0  ( c1  ),
    .io_class_voc_1  ( c2  ),
    .io_class_voc_2  ( c3  ),
    .io_class_voc_3  ( c4 ),
    .io_class_voc_4  ( c5 ),
    .io_rect_xleft_0 ( xleft1 ),
    .io_rect_xleft_1 ( xleft2 ),
    .io_rect_xleft_2 ( xleft3 ),
    .io_rect_xleft_3 ( xleft4 ),
    .io_rect_xleft_4 ( xleft5 ),
    .io_rect_ytop_0  ( ytop1  ),
    .io_rect_ytop_1  ( ytop2  ),
    .io_rect_ytop_2  ( ytop3  ),
    .io_rect_ytop_3  ( ytop4  ),
    .io_rect_ytop_4  ( ytop5  ),
    .io_pixel        ( io_pixel ),
    .io_char_area_valid_0 ( char_area_valid_0 ),
    .io_char_area_valid_1 ( char_area_valid_1 ),
    .io_char_area_valid_2 ( char_area_valid_2 ),
    .io_char_area_valid_3 ( char_area_valid_3 ),
    .io_char_area_valid_4 ( char_area_valid_4 )
);

reg io_pixel_t;
reg char_area_valid_0_t;
reg char_area_valid_1_t;
reg char_area_valid_2_t;
reg char_area_valid_3_t;
reg char_area_valid_4_t;
always @(posedge i_clk) begin
    io_pixel_t <= io_pixel;
    char_area_valid_0_t <= char_area_valid_0;
    char_area_valid_1_t <= char_area_valid_1;
    char_area_valid_2_t <= char_area_valid_2;
    char_area_valid_3_t <= char_area_valid_3;
    char_area_valid_4_t <= char_area_valid_4;
end

// 同步数据
//多目标
reg         o_de_t;
reg         o_hsyn_t;
reg         o_vsyn_t;
reg [23:0]  o_data_t;
always @(posedge i_clk) begin
    if(h_cnt < H_LEFT || h_cnt > H_RIGHT || v_cnt < V_LEFT || v_cnt > V_RIGHT)
        o_data_t <= 0;
    else if(o_valid_t1 | o_valid_t2 | o_valid_t3 | o_valid_t4 | o_valid_t5)
        o_data_t <= (o_data_t1 | o_data_t2 | o_data_t3 | o_data_t4 | o_data_t5);
    else 
        o_data_t <= i_data;
        
    o_hsyn_t <= i_hsyn;
    o_vsyn_t <= i_vsyn;
    o_de_t <= i_de;
    
    o_data <= o_data_t;
    o_hsyn <= o_hsyn_t;
    o_vsyn <= o_vsyn_t;
    o_de <= o_de_t;
end


endmodule









