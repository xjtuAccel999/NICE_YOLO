module cal_class_x1(
    input clk,
    input rst,
    input yolo_layer_finish,
    input en,  
    input [3:0] trans_cnt,
    input [1:0] anchor_sel_t,
    input [7:0] cmax8_value_x,
    input [2:0] cmax8_index_x,
    output reg [7:0] cmax,
    output reg [6:0] cindex
);

always @(posedge clk) begin
    if(rst || yolo_layer_finish) begin
        cmax <= 0;
        cindex <= 0;
    end
    else if(en)begin
        if(trans_cnt  == 1 && anchor_sel_t == 1) begin
            cmax <= cmax8_value_x;
            cindex <= cmax8_index_x - 5;
        end
        else if(cmax < cmax8_value_x) begin
            cmax <= cmax8_value_x;  
            cindex <= (trans_cnt<<3) + cmax8_index_x - 13;    
            //cindex = (trans_cnt - 1)*8+cmax_index-5    
        end
    end
end


endmodule