module interface_nice(
    input           clk,
    input           rst_n,
    // input           ila_clk,

    input             nice_acr_cmd_valid,
    output reg        nice_acr_cmd_ready,
    input      [5:0]  nice_acr_cmd_addr ,
    input             nice_acr_cmd_read ,
    input      [31:0] nice_acr_cmd_wdata,
    output reg        nice_acr_rsp_valid,
    input             nice_acr_rsp_ready,
    output reg [31:0] nice_acr_rsp_rdata,   
    input             nice_rsp_ready,

    //accel_recv_data
    output reg [5:0]  accel_addr,
    output reg [31:0] accel_data,
    output reg        accel_valid,
    
    //hdmi_recv_data
    output reg [5:0]  hdmi_addr,
    output reg [31:0] hdmi_data,
    output reg        hdmi_valid,

    //yolo_layer_data  use dual port ram
    output reg [5:0]  yolo_addr,
    input      [31:0] yolo_data
);

reg [4:0] cur_state;
reg [4:0] next_state;
localparam s_idle = 5'b00001;
localparam s_recv = 5'b00010;
localparam s_w    = 5'b00100;
localparam s_r    = 5'b01000;
localparam s_rsp  = 5'b10000;


reg [5:0]  addr;
reg [31:0] w_data;
reg        rw; //r=1 w=0
reg  [1:0] cnt;

// ila_0 u_ila(
//     .clk    (ila_clk),
//     .probe0 ({nice_acr_cmd_valid,nice_acr_cmd_ready,nice_acr_cmd_addr,nice_acr_cmd_read,nice_acr_rsp_valid,nice_acr_rsp_ready,
//               nice_rsp_ready,cnt,next_state,cur_state,addr,rw,accel_addr,accel_valid,hdmi_addr,hdmi_valid,yolo_addr}),
//     .probe1 ({nice_acr_cmd_wdata,nice_acr_rsp_rdata}),
//     .probe2 ({hdmi_data,accel_data}),
//     .probe3 ({yolo_data,w_data})
// );


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        cur_state <= s_idle;
    else 
        cur_state <= next_state;
end

always @(*) begin
    case(cur_state)
        s_idle:begin
            if(nice_acr_cmd_valid)
                next_state = s_recv;
            else
                next_state = s_idle;
        end
        s_recv:begin
            if(rw)
                next_state = s_r;
            else 
                next_state = s_w;
        end
        s_w:begin
            next_state = s_rsp;
        end
        s_r:begin
            if(cnt == 2)
                next_state = s_rsp;
            else 
                next_state = s_r;
        end
        s_rsp:begin
            next_state = s_idle;
        end
    endcase
end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
        addr <= 0;
        w_data <= 0;
        rw <= 0;
        accel_addr <= 0;
        accel_data <= 0;
        accel_valid <= 0;
        hdmi_addr <= 0;
        hdmi_data <= 0;
        hdmi_valid <= 0;
        nice_acr_cmd_ready <= 0;
        nice_acr_rsp_valid <= 0;
        nice_acr_rsp_rdata <= 0;
        yolo_addr <= 0;
    end
    else begin
        case(next_state)
            s_idle:begin
                nice_acr_cmd_ready <= 1;
                nice_acr_rsp_valid <= 0;
            end
            s_recv:begin
                addr <= nice_acr_cmd_addr;
                w_data <= nice_acr_cmd_wdata;
                rw <= nice_acr_cmd_read;
                nice_acr_cmd_ready <= 0;
            end
            s_w:begin
                if(addr < 30 && addr > 20) begin
                    accel_addr <= addr;
                    accel_data <= w_data;
                    accel_valid <= 1;
                end
                else if(addr < 40 && addr > 29) begin
                    hdmi_addr <= addr;
                    hdmi_data <= w_data;
                    hdmi_valid <= 1;
                end
            end
            s_r:begin
                yolo_addr <= addr;
                cnt <= cnt + 1;
            end
            s_rsp:begin
                cnt <= 0;
                accel_valid <= 0;
                hdmi_valid <= 0;
                nice_acr_rsp_valid <= 1;
                nice_acr_rsp_rdata <= yolo_data;
            end
        endcase
    end
end

endmodule