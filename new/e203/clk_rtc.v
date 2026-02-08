
/***************************************************************/
//功能: 偶数分频
//描述:
//      DIV_NUM为分频系数
/***************************************************************/

module clk_rtc #(
	parameter			DIV_NUM = 6)
(
	input				clk,
	input				rst_n,
	output	reg			pclk
    );
	


function	integer		logb2;
	input		integer		depth;
	for(logb2 = 0; depth > 0; logb2 = logb2 + 1) begin
		depth = depth >> 1;
	end
endfunction

reg		[logb2(DIV_NUM) - 1 :0]		div_cnt;
	
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pclk <= 0;
		div_cnt <= 0;
	end
	else begin
		if(div_cnt < DIV_NUM - 1) begin
			div_cnt <= div_cnt + 1;
			if(div_cnt < DIV_NUM/2)
				pclk <= 1'b0;
			else 
				pclk <= 1'b1;
		end
		else
			div_cnt <= 0;
	end
end	
	
endmodule
