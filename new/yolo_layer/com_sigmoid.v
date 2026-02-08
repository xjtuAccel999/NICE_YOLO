module com_sigmoid(
    input        clk,
    input  [7:0] addr,
    input        en,

    output [13:0] data_frac,
    output [3:0]  data_exp
);

sigmoidExpData u_sigmoidExpData(
    .clka   ( clk       ),
    .addra  ( addr      ),
    .ena    ( en        ),
    .douta  ( data_exp  )
);


sigmoidFracData u_sigmoidFracData(
    .clka  ( clk        ),
    .addra ( addr       ),
    .ena   ( en         ),
    .douta ( data_frac  )
);


endmodule