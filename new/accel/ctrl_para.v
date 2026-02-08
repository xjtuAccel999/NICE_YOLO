
//参数
`define   relu_type   1'b0
`define   WEIGHT_LEN  128

//寄存器参数
`define RECV_ENABLE					32'h00000001
`define SEND_ENABLE					32'h00000002
`define	IFM_BUF_SEL					32'h00000000
`define	WEIGHT_BUF_SEL				32'h00000004
`define LEAKY_RELU_BUF				32'h00000008
`define BIAS_BUF_SEL				32'h0000000C
`define CONV_START_CMD			    32'h00000010
`define FIRST_CONV				    32'h00000040
`define LAST_CONV				    32'h00000080
`define IFM_SEL					    32'h00000100
`define TASK_VALID				    32'h00000200
`define OFM_SEND_WHOLE				2'd0
`define OFM_SEND_NO_HEAD			2'd1
`define OFM_SEND_NO_TAIL			2'd2
`define OFM_SEND_REDUCE				2'd3

//地址参数
`define ifmInBuf0 32'h35000000
`define ifmInBuf1 32'h36000000
// `define ifmInBuf0 32'h72000000
// `define ifmInBuf1 32'h72000000
`define FM_BUF_0  32'h20000000
`define FM_BUF_1  32'h22000000
`define FM_BUF_2  32'h24000000

`define WEIGHT0   32'h60000000
`define WEIGHT1   32'h61000000
`define WEIGHT2   32'h62000000
`define WEIGHT3   32'h63000000
`define WEIGHT4   32'h64000000
`define WEIGHT5   32'h65000000
`define WEIGHT6   32'h66000000
`define WEIGHT7   32'h67000000
`define WEIGHT8   32'h68000000
`define WEIGHT9   32'h69000000

`define BIAS0     32'h40000000
`define BIAS1     32'h41000000
`define BIAS2     32'h42000000
`define BIAS3     32'h43000000
`define BIAS4     32'h44000000
`define BIAS5     32'h45000000
`define BIAS6     32'h46000000
`define BIAS7     32'h47000000
`define BIAS8     32'h48000000
`define BIAS9     32'h49000000

`define LEAKY0    32'h50000000
`define LEAKY1    32'h51000000
`define LEAKY2    32'h52000000
`define LEAKY3    32'h53000000
`define LEAKY4    32'h54000000
`define LEAKY5    32'h55000000
`define LEAKY6    32'h56000000
`define LEAKY7    32'h57000000
`define LEAKY8    32'h58000000
`define LEAKY9    32'h59000000
 



//状态机参数
`define   INIT_IDLE             6'd0
`define   INIT_SEND_DMA_BIA_0   6'd1
`define   INIT_SEND_DMA_BIA_1   6'd2
`define   INIT_SEND_DMA_BIA_2   6'd3
`define   INIT_SEND_DMA_LKY_0   6'd4
`define   INIT_SEND_DMA_LKY_1   6'd5
`define   INIT_SEND_DMA_LKY_2   6'd6
`define   INIT_SEND_DMA_WGT_0   6'd7
`define   INIT_SEND_DMA_WGT_1   6'd8
`define   INIT_SEND_DMA_WGT_2   6'd9
`define   INIT_NEXT_IFM_ADDR_0  6'd10
`define   INIT_NEXT_IFM_ADDR_1  6'd11
`define   INIT_SET_REG0         6'd12
`define   INIT_SET_REG1         6'd13
`define   INIT_SET_REG2         6'd14
`define   INIT_SET_REG3         6'd15

`define   IFM_SEND_IFM0         6'd16
`define   IFM_SEND_IFM1         6'd17
`define   IFM_SEND_IFM2         6'd18
`define   IFM_NEXT_OFM_ADDR_0   6'd19
`define   IFM_NEXT_OFM_ADDR_1   6'd20
`define   IFM_NEXT_OFM0_ADDR_0  6'd21
`define   IFM_NEXT_OFM0_ADDR_1  6'd22
`define   IFM_NEXT_OFM1_ADDR_0  6'd23
`define   IFM_NEXT_OFM1_ADDR_1  6'd24
`define   IFM_NEXT_WGT_ADDR     6'd25
`define   IFM_UPDATA_ITER_0     6'd26
`define   IFM_UPDATA_ITER_1     6'd27
`define   IFM_UPDATA_ITER_2     6'd28
`define   IFM_NEXT_IFM_ADDR_0   6'd29
`define   IFM_NEXT_IFM_ADDR_1   6'd30
`define   IFM_SET_REG0          6'd31
`define   IFM_SET_REG1          6'd32
`define   IFM_SET_REG2          6'd33
`define   IFM_SET_REG3          6'd34
`define   IFM_WGT_ADDR_READ_0   6'd35
`define   IFM_WGT_ADDR_READ_1   6'd36

`define   OFM_WGT_STATE_0       6'd37
`define   OFM_RECV_0            6'd38
`define   OFM_RECV_1            6'd39
`define   OFM_RECV_2            6'd40
`define   OFM_RECV_3            6'd41
`define   OFM_UPDATA_ITER_0     6'd42
`define   OFM_UPDATA_ITER_1     6'd43
`define   OFM_NEXT_IFM_ADDR_0   6'd44
`define   OFM_NEXT_IFM_ADDR_1   6'd45
`define   OFM_SET_REG0          6'd46
`define   OFM_SET_REG1          6'd47
`define   OFM_SET_REG2          6'd48
`define   OFM_SET_REG3          6'd49
`define   OFM_WGT_ADDR_READ_0   6'd50
`define   OFM_WGT_ADDR_READ_1   6'd51
`define   OFM_WGT_STATE_1       6'd52
`define   WGT_SEND_0            6'd53
`define   WGT_SEND_1            6'd54
`define   WGT_SEND_2            6'd55
`define   ALL_TASK_FINISH       6'd56
`define   WAIT_YOLO_FINSH       6'd57
`define   WAIT_YOLO_CLR         6'd58