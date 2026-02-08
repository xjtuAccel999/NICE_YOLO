module cal_comparator_1x8(
    input clk,
    input rst,
    input yolo_layer_finish,
    input [63:0] data_i,

    output  [7:0] max_data,
    output  [2:0] max_index
);

wire [7:0] data0;
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;
wire [7:0] data4;
wire [7:0] data5;
wire [7:0] data6;
wire [7:0] data7;
assign data0 = data_i[7:0];
assign data1 = data_i[15:8];
assign data2 = data_i[23:16];
assign data3 = data_i[31:24];
assign data4 = data_i[39:32];
assign data5 = data_i[47:40];
assign data6 = data_i[55:48];
assign data7 = data_i[63:56];

reg [7:0] max_data_t0;
reg [2:0] max_index_t0;

reg [7:0] max_data_t1;
reg [2:0] max_index_t1;

reg [7:0] max_data_t2;
reg [2:0] max_index_t2;

reg [7:0] max_data_t3;
reg [2:0] max_index_t3;

//从8个里面比较出4个
always @(posedge clk) begin
    if(rst || yolo_layer_finish)begin
        max_data_t0 <= 0;
        max_index_t0 <= 0;
    end
    else if(data0 > data1) begin
        max_data_t0 = data0;
        max_index_t0 = 0;
    end
    else begin
        max_data_t0 = data1;
        max_index_t0 = 1;
    end

    if(rst || yolo_layer_finish)begin
        max_data_t1 <= 0;
        max_index_t1 <= 0;
    end
    else if(data2 > data3) begin
        max_data_t1 = data2;
        max_index_t1 = 2;
    end
    else begin
        max_data_t1 = data3;
        max_index_t1 = 3;
    end

    if(rst || yolo_layer_finish)begin
        max_data_t2 <= 0;
        max_index_t2 <= 0;
    end
    else if(data4 > data5) begin
        max_data_t2 = data4;
        max_index_t2 = 4;
    end
    else begin
        max_data_t2 = data5;
        max_index_t2 = 5;
    end

    if(rst || yolo_layer_finish)begin
        max_data_t3 <= 0;
        max_index_t3 <= 0;
    end    
    else if(data6 > data7) begin
        max_data_t3 = data6;
        max_index_t3 = 6;
    end
    else begin
        max_data_t3 = data7;
        max_index_t3 = 7;
    end
end

//从4个里面比较出2个
reg [7:0] max_data_t4;
reg [2:0] max_index_t4;

reg [7:0] max_data_t5;
reg [2:0] max_index_t5;

always @(posedge clk) begin
    if(rst || yolo_layer_finish)begin
        max_data_t4 <= 0;
        max_index_t4 <= 0;
    end   
    else if(max_data_t0 > max_data_t1) begin
        max_data_t4 = max_data_t0;
        max_index_t4 = max_index_t0;
    end
    else begin
        max_data_t4 = max_data_t1;
        max_index_t4 = max_index_t1;
    end

    if(rst || yolo_layer_finish)begin
        max_data_t5 <= 0;
        max_index_t5 <= 0;
    end  
    else if(max_data_t2 > max_data_t3) begin
        max_data_t5 = max_data_t2;
        max_index_t5 = max_index_t2;
    end
    else begin
        max_data_t5 = max_data_t3;
        max_index_t5 = max_index_t3;
    end
end

//从2个里面比较出1个
reg [7:0] max_data_t;
reg [2:0] max_index_t;
always @(posedge clk) begin
    if(rst || yolo_layer_finish)begin
        max_data_t <= 0;
        max_index_t <= 0;
    end  
    else if(max_data_t4 > max_data_t5) begin
        max_data_t <= max_data_t4;
        max_index_t <= max_index_t4;
    end
    else begin
        max_data_t <= max_data_t5;
        max_index_t <= max_index_t5;
    end
end

assign max_data = max_data_t;
assign max_index = max_index_t;

endmodule