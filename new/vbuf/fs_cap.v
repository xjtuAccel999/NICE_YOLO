`timescale 1ns / 1ps


module fs_cap(
    input  clk_i,
    input  rstn_i,
    input  vs_i,
    output reg fs_cap_o
    );
    

reg[4:0]CNT_FS   = 6'b0;
reg[4:0]CNT_FS_n = 6'b0;
reg     FS       = 1'b0;
(* ASYNC_REG = "TRUE" *)   reg vs_i_r1;
(* ASYNC_REG = "TRUE" *)   reg vs_i_r2;
(* ASYNC_REG = "TRUE" *)   reg vs_i_r3;
(* ASYNC_REG = "TRUE" *)   reg vs_i_r4;

    always@(posedge clk_i) begin
            vs_i_r1 <= vs_i;
            vs_i_r2 <= vs_i_r1;
            vs_i_r3 <= vs_i_r2;
            vs_i_r4 <= vs_i_r3;
    end

    always@(posedge clk_i) begin
         if(!rstn_i)begin
            fs_cap_o <= 1'd0;
         end
         else if({vs_i_r4,vs_i_r3} == 2'b01)begin
            fs_cap_o <= 1'b1;
         end
         else begin
            fs_cap_o <= 1'b0;
         end
    end
        
endmodule
