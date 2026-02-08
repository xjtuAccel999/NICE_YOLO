module cal_class_x5(
    input clk,
    input rst,
    input yolo_layer_finish,
    input en,  
    input [1:0] anchor_sel_t,
    input [3:0] trans_cnt,
    input [7:0] cmax8_value_1,
    input [7:0] cmax8_value_2,
    input [7:0] cmax8_value_3,
    input [7:0] cmax8_value_4,
    input [7:0] cmax8_value_5,
    input [2:0] cmax8_index_1,
    input [2:0] cmax8_index_2,
    input [2:0] cmax8_index_3,
    input [2:0] cmax8_index_4,
    input [2:0] cmax8_index_5,
    output [7:0] cmax1,
    output [7:0] cmax2,
    output [7:0] cmax3,
    output [7:0] cmax4,
    output [7:0] cmax5,
    output [6:0] cindex1, 
    output [6:0] cindex2, 
    output [6:0] cindex3, 
    output [6:0] cindex4, 
    output [6:0] cindex5
);

cal_class_x1 u1_cal_class_x1(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .anchor_sel_t      ( anchor_sel_t      ),
    .en                ( en                ),
    .cmax8_value_x     ( cmax8_value_1     ),
    .cmax8_index_x     ( cmax8_index_1     ),
    .trans_cnt         ( trans_cnt         ),
    .cmax              ( cmax1             ),
    .cindex            ( cindex1           )
);

cal_class_x1 u2_cal_class_x1(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .anchor_sel_t      ( anchor_sel_t      ),
    .en                ( en                ),
    .cmax8_value_x     ( cmax8_value_2     ),
    .cmax8_index_x     ( cmax8_index_2     ),
    .trans_cnt         ( trans_cnt         ),
    .cmax              ( cmax2             ),
    .cindex            ( cindex2           )
);

cal_class_x1 u3_cal_class_x1(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .anchor_sel_t      ( anchor_sel_t      ),
    .en                ( en                ),
    .cmax8_value_x     ( cmax8_value_3     ),
    .cmax8_index_x     ( cmax8_index_3     ),
    .trans_cnt         ( trans_cnt         ),
    .cmax              ( cmax3             ),
    .cindex            ( cindex3           )
);

cal_class_x1 u4_cal_class_x1(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .anchor_sel_t      ( anchor_sel_t      ),
    .en                ( en                ),
    .cmax8_value_x     ( cmax8_value_4     ),
    .cmax8_index_x     ( cmax8_index_4     ),
    .trans_cnt         ( trans_cnt         ),
    .cmax              ( cmax4             ),
    .cindex            ( cindex4           )
);

cal_class_x1 u5_cal_class_x1(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .yolo_layer_finish ( yolo_layer_finish ),
    .anchor_sel_t      ( anchor_sel_t      ),
    .en                ( en                ),
    .cmax8_value_x     ( cmax8_value_5     ),
    .cmax8_index_x     ( cmax8_index_5     ),
    .trans_cnt         ( trans_cnt         ),
    .cmax              ( cmax5             ),
    .cindex            ( cindex5           )
);

endmodule