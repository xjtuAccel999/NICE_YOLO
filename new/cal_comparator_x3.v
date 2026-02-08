module cal_comparator_x3(
    input clk,
    input [23:0] data_i,

    output reg [7:0] max_data,
    output reg [1:0] max_index
);

wire [7:0] data0;
wire [7:0] data1;
wire [7:0] data2;
assign data0 = data_i[7:0];
assign data1 = data_i[15:8];
assign data2 = data_i[23:16];

reg [7:0] max_data_t;
reg [1:0] max_index_t;

always @(posedge clk) begin
    if(data0 > data1) begin
        max_data_t = data0;
        max_index_t = 0;
    end
    else begin
        max_data_t = data1;
        max_index_t = 1;
    end
end

always @(posedge clk) begin
    if(data2 > max_data_t) begin
        max_data <= data2;
        max_index <= 2;
    end
    else begin
        max_data <= max_data_t;
        max_index <= max_index_t;
    end
end

endmodule