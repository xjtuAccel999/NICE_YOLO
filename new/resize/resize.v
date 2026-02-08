module resize
#(
    parameter  H_ACTIVE = 1920, //显示区域宽度                              
    parameter  V_ACTIVE = 1080,  //显示区域高度
    parameter  H_OUTPUT = 418,
    parameter  V_OUTPUT = 258,
    parameter  H_LEFT = (H_ACTIVE - 4*H_OUTPUT)/2,
    parameter  H_RIGHT = H_ACTIVE - H_LEFT,
    parameter  V_LEFT = (V_ACTIVE - 4*V_OUTPUT)/2,
    parameter  V_RIGHT = V_ACTIVE - V_LEFT
)
(
    input i_clk,
    input i_rst_n,
    input start,
    input i_de,
    input [23:0] i_data,
    output reg o_de,
    output reg [23:0] o_data
);

localparam [1:0] IDLE=0, WAIT=1, TRAN=2;

reg  [10:0] 	    h_cnt;
reg  [10:0] 	    v_cnt;
reg  [1:0]          state,next;
wire [7:0] data1, data2, data3;
reg start_reg0, start_reg1;
wire edge_start;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)begin
        start_reg0 <= 0;
        start_reg1 <= 0;
    end
    else begin
        start_reg0 <= start;
        start_reg1 <= start_reg0;
    end
end

assign edge_start = start_reg0 ^ start_reg1;


assign data1 = {1'b0,i_data[7:1]};
assign data2 = {1'b0,i_data[15:9]};
assign data3 = {1'b0,i_data[23:17]};


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

always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= next;
    end
end

always@(*)begin
    case(state)
        IDLE:begin
            if(edge_start)   next = WAIT;
            else        next = IDLE;
        end

        WAIT:begin
            if(v_cnt==1)    next = TRAN;
            else            next = WAIT;
        end

        TRAN:begin
            if(v_cnt==0)    next = IDLE;
            else            next = TRAN;
        end
    endcase
end


always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_de <= 0;
        o_data <= 0;
    end
    else if(state == TRAN) begin
        if( (h_cnt < H_LEFT) || (h_cnt >= H_RIGHT) || (v_cnt < V_LEFT) || (v_cnt >= V_RIGHT) )begin
            o_de <= 0;
            o_data <= 0;
        end
        else if( (h_cnt[1:0] != 0) || (v_cnt[1:0] != 0) )begin
            o_de <= 0;
            o_data <= 0;
        end
        else begin
            o_de <= 1;
            o_data <= {data1, data2, data3};
        end
    end
    else begin
        o_de <= 0;
        o_data <= 0;
    end
end

endmodule