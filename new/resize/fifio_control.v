`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/17 11:41:52
// Design Name: 
// Module Name: fifio_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
/* 一个像素是24bit，输出的数据是64bit，当fifo的full信号为0，且in_de为1说明数据有效时，
将in_data补0进行输出，且wr_en也置为1
*/
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_control(
    input clk,rst_n,in_de,full,
    output reg wr_en,
    input [23:0] in_data,
    output reg [63:0] out_data


    );
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_data <= 0;
            wr_en <= 0;
        end
        else if(in_de && !full)begin
            out_data <= {40'd0,in_data};
            wr_en <= 1;
        end
        else begin
            wr_en <= 0;
        end
    end



endmodule
