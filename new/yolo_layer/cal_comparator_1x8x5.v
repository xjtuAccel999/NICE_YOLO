module cal_comparator_1x8x5(
    input clk,
    input rst,
    input yolo_layer_finish,
    input [63:0] pc1,
    input [63:0] pc2,
    input [63:0] pc3,
    input [63:0] pc4,
    input [63:0] pc5,
    output [7:0] cmax8_value_1,
    output [7:0] cmax8_value_2,
    output [7:0] cmax8_value_3,
    output [7:0] cmax8_value_4,
    output [7:0] cmax8_value_5,
    output [2:0] cmax8_index_1,
    output [2:0] cmax8_index_2,
    output [2:0] cmax8_index_3,
    output [2:0] cmax8_index_4,
    output [2:0] cmax8_index_5
);

cal_comparator_1x8 u1_cal_comparator_1x8(
    .clk               ( clk           ),
    .rst               ( rst           ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .data_i            ( pc1           ),
    .max_data          ( cmax8_value_1 ),
    .max_index         ( cmax8_index_1 )
);

cal_comparator_1x8 u2_cal_comparator_1x8(
    .clk               ( clk           ),
    .rst               ( rst           ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .data_i            ( pc2           ),
    .max_data          ( cmax8_value_2 ),
    .max_index         ( cmax8_index_2 )
);

cal_comparator_1x8 u3_cal_comparator_1x8(
    .clk               ( clk           ),
    .rst               ( rst           ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .data_i            ( pc3           ),
    .max_data          ( cmax8_value_3 ),
    .max_index         ( cmax8_index_3 )
);

cal_comparator_1x8 u4_cal_comparator_1x8(
    .clk               ( clk           ),
    .rst               ( rst           ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .data_i            ( pc4           ),
    .max_data          ( cmax8_value_4 ),
    .max_index         ( cmax8_index_4 )
);

cal_comparator_1x8 u5_cal_comparator_1x8(
    .clk               ( clk           ),
    .rst               ( rst           ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .data_i            ( pc5           ),
    .max_data          ( cmax8_value_5 ),
    .max_index         ( cmax8_index_5 )
);

endmodule