`timescale 1ns / 1ps
module uidelay#
(
	parameter[31:0]num = 32'h00ffff00
)(
	input clk_i,
	input rstn_i,
	output rst_o
    );

reg[31:0] cnt = 32'd0;
reg rst_d0;

/*count for clock*/
always@(posedge clk_i)
begin 
    if(!rstn_i)
    begin
       cnt<=32'd0; 
    end
    else if(cnt < num)begin
	   cnt <= cnt + 1'b1;
	end
end

/*generate output signal*/
always@(posedge clk_i)
begin
    if(!rstn_i)
    begin
        rst_d0 <= 1'b0; 
    end
    else begin
	   rst_d0 <= ( cnt == num);
	end
end	

assign rst_o = rst_d0;

endmodule

