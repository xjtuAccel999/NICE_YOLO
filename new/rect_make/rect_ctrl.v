module rect_ctrl(
    input i_clk,
    input i_rst_n,

    input e203_clk,

    input i_hsyn,
    input i_vsyn,
    input i_de,
    input [23:0] i_data,
    
    input i_rect_en,
    input i_rect_clr,
    input [5:0] addr,
    input [31:0] data,
    input valid,

    output           o_hsyn,
    output           o_vsyn,
    output           o_de,
    output    [23:0] o_data

);

// ila_0 u_ila(
//     .clk    (i_clk),
//     .probe0 ({i_rect_en,e203_clk,addr_t,valid_t,addr,i_rect_en_up_edge,cnt,cnt_en,cnt_t,rect_updata_en,cnt_en_t,i_rect_clr}),
//     .probe1 ({rect_data,data_t}),
//     .probe2 ({reg0_rect1,reg1_rect1}),
//     .probe3 ({reg0_rect2,reg1_rect2})
// );

reg [3:0] addr_t;
reg       valid_t,valid_t0;
reg [31:0] data_t;
always @(posedge e203_clk) begin
    valid_t0 <= valid;
    valid_t <= valid_t0;
    addr_t <= addr - 30;
    data_t <= data;
end

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

reg [3:0] cnt;
reg       cnt_en;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        cnt <= 0;
        cnt_en <= 0;
    end
    else if(i_rect_en_up_edge) 
        cnt_en <= 1;
    else if(cnt_en) begin
        if(cnt == 9) begin
            cnt <= 0;
            cnt_en <= 0;
        end
        else 
            cnt <= cnt + 1;
    end
end

wire [31:0] rect_data;

blk_mem_gen_0 rect_ram (
  .clka (e203_clk ),      // input wire clka
  .ena  (valid_t  ),      // input wire ena
  .wea  (1'b1     ),      // input wire [0 : 0] wea
  .addra(addr_t   ),      // input wire [4 : 0] addra
  .dina (data_t   ),      // input wire [31 : 0] dina
  .douta(         ),      // output wire [31 : 0] douta
  .clkb (i_clk    ),      // input wire clkb
  .enb  (cnt_en   ),      // input wire enb
  .web  (1'b0     ),      // input wire [0 : 0] web
  .addrb(cnt      ),      // input wire [4 : 0] addrb
  .dinb (         ),      // input wire [31 : 0] dinb
  .doutb(rect_data)       // output wire [31 : 0] doutb
);

reg [3:0] cnt_t;
reg       cnt_en_t;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        cnt_t <= 0;
        cnt_en_t <= 0;
    end
    else begin
        cnt_t <= cnt;
        cnt_en_t <= cnt_en;
    end
end

reg [31:0] reg0_rect1;
reg [31:0] reg1_rect1;
reg [31:0] reg0_rect2;
reg [31:0] reg1_rect2;
reg [31:0] reg0_rect3;
reg [31:0] reg1_rect3;
reg [31:0] reg0_rect4;
reg [31:0] reg1_rect4;
reg [31:0] reg0_rect5;
reg [31:0] reg1_rect5;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        reg0_rect1 <= 0;
        reg1_rect1 <= 0;
        reg0_rect2 <= 0;
        reg1_rect2 <= 0;
        reg0_rect3 <= 0;
        reg1_rect3 <= 0;
        reg0_rect4 <= 0;
        reg1_rect4 <= 0;
        reg0_rect5 <= 0;
        reg1_rect5 <= 0;
    end
    else if(i_rect_clr) begin
        reg0_rect1 <= 0;
        reg1_rect1 <= 0;
        reg0_rect2 <= 0;
        reg1_rect2 <= 0;
        reg0_rect3 <= 0;
        reg1_rect3 <= 0;
        reg0_rect4 <= 0;
        reg1_rect4 <= 0;
        reg0_rect5 <= 0;
        reg1_rect5 <= 0;
    end
    else if(cnt_en_t) begin
        case(cnt_t)
            4'd0: reg0_rect1 <= rect_data;
            4'd1: reg1_rect1 <= rect_data;
            4'd2: reg0_rect2 <= rect_data;
            4'd3: reg1_rect2 <= rect_data;
            4'd4: reg0_rect3 <= rect_data;
            4'd5: reg1_rect3 <= rect_data;
            4'd6: reg0_rect4 <= rect_data;
            4'd7: reg1_rect4 <= rect_data;
            4'd8: reg0_rect5 <= rect_data;
            4'd9: reg1_rect5 <= rect_data;
            default:;
        endcase
    end
end

wire rect_updata_en;
assign rect_updata_en = (cnt_t == 9);


rectangle_make u_rectangle_make(
    .i_clk       ( i_clk       ),
    .i_rst_n     ( i_rst_n     ),
    .i_hsyn      ( i_hsyn      ),
    .i_vsyn      ( i_vsyn      ),
    .i_de        ( i_de        ),
    .i_data      ( i_data      ),
    .i_rect_en   ( rect_updata_en ),  
    .reg0_rect1  ( reg0_rect1  ),
    .reg1_rect1  ( reg1_rect1  ),
    .reg0_rect2  ( reg0_rect2  ),
    .reg1_rect2  ( reg1_rect2  ),
    .reg0_rect3  ( reg0_rect3  ),
    .reg1_rect3  ( reg1_rect3  ),
    .reg0_rect4  ( reg0_rect4  ),
    .reg1_rect4  ( reg1_rect4  ),
    .reg0_rect5  ( reg0_rect5  ),
    .reg1_rect5  ( reg1_rect5  ),
    .o_hsyn      ( o_hsyn      ),
    .o_vsyn      ( o_vsyn      ),
    .o_de        ( o_de        ),
    .o_data      ( o_data      )
);


endmodule