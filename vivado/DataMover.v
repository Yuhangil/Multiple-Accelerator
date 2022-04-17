`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 17:22:37
// Design Name: 
// Module Name: DataMover
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module DataMover
#(
    parameter CNT = 31,
    
    parameter DWIDTH = 32,
    parameter AWIDTH = 12,
    parameter MEM_SIZE = 4096,
    parameter IN_DATA_WIDTH = 8
)
(
    input clk,
    input reset_n,
    input i_run,
    input [CNT-1:0] i_num_cnt,
    output o_idle,
    output o_read,
    output o_write,
    output o_done,
    
    // Memory I/F (Bram0)
    output [AWIDTH-1:0] addr_b0,
    output ce_b0,
    output we_b0,
    input [DWIDTH-1:0] q0_b0,
    output [DWIDTH-1:0] d0_b0,
    
    // Memory I/F (Bram1)
    output [AWIDTH-1:0] addr_b1,
    output ce_b1,
    output we_b1,
    input [DWIDTH-1:0] q0_b1,
    output [DWIDTH-1:0] d0_b1
);

    localparam S_IDLE = 2'b00;
    localparam S_RUN = 2'b01;
    localparam S_DONE = 2'b10;
    
    reg [1:0] c_state_read;
    reg [1:0] c_state_write;
    reg [1:0] n_state_read;
    reg [1:0] n_state_write;
    
    wire is_write_done;
    wire is_read_done;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            c_state_read <= S_IDLE;
        end else begin
            c_state_read <= n_state_read;
        end
    end
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            c_state_write <= S_IDLE;
        end else begin
            c_state_write <= n_state_write;
        end
    end
    
    always@(*) begin
        n_state_read = c_state_read;
        case(c_state_read)
            S_IDLE:
                if(i_run) begin
                    n_state_read = S_RUN;
                end
            S_RUN:
                if(is_read_done) begin
                    n_state_read = S_DONE;
                end
            S_DONE:
                n_state_read = S_IDLE;
        endcase
    end
    
    always@(*) begin
        n_state_write = c_state_write;
        case(c_state_write)
            S_IDLE:
                if(i_run) begin
                    n_state_write = S_RUN;
                end
            S_RUN:
                if(is_write_done) begin
                    n_state_write = S_DONE;
                end
            S_DONE:
                n_state_write = S_IDLE;
        endcase
    end
    
    assign o_idle = (c_state_read == S_IDLE) && (c_state_write == S_IDLE);
    assign o_read = (c_state_read == S_RUN);
    assign o_write = (c_state_write == S_RUN);
    assign o_done = (c_state_write == S_DONE);
    
    reg [CNT-1:0] num_cnt;
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            num_cnt <=0;
        end else if(i_run) begin
            num_cnt <= i_num_cnt;
        end else if(o_done) begin
            num_cnt <= 0;
        end
    end
    
    reg [CNT-1:0] addr_cnt_read;
    reg [CNT-1:0] addr_cnt_write;
    
    assign is_read_done = o_read && (addr_cnt_read == num_cnt-1);
    assign is_write_done = o_write && (addr_cnt_write == num_cnt-1);
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            addr_cnt_read <= 0;
        end else if(is_read_done) begin
            addr_cnt_read <= 0;
        end else if(o_read) begin
            addr_cnt_read <= addr_cnt_read + 1;
        end
    end
    
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            addr_cnt_write <= 0;
        end else if(is_write_done) begin
            addr_cnt_write <= 0;
        end else if(o_write && we_b1) begin
            addr_cnt_write <= addr_cnt_write + 1;
        end
    end
    
    assign addr_b0 = addr_cnt_read;
    assign ce_b0 = o_read;
    assign we_b0 = 1'b0;
    assign d0_b0 = {DWIDTH{1'b0}};
    
    reg r_valid;
    wire [DWIDTH-1:0] mem_data;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_valid <= {DWIDTH{1'b0}};
        end else begin
            r_valid <= o_read;
        end
    end
    
    assign mem_data = q0_b0;
    
    wire [IN_DATA_WIDTH-1:0] write_A_0 = mem_data[(1*IN_DATA_WIDTH)-1:(0*IN_DATA_WIDTH)];
    wire [IN_DATA_WIDTH-1:0] write_B_0 = mem_data[(2*IN_DATA_WIDTH)-1:(1*IN_DATA_WIDTH)];
    
    wire [(2*IN_DATA_WIDTH)-1:0] write_result_0;
    wire write_valid_0;
    
    wire [IN_DATA_WIDTH-1:0] write_A_1 = mem_data[(3*IN_DATA_WIDTH)-1:(2*IN_DATA_WIDTH)];
    wire [IN_DATA_WIDTH-1:0] write_B_1 = mem_data[(4*IN_DATA_WIDTH)-1:(3*IN_DATA_WIDTH)];
    
    wire [(2*IN_DATA_WIDTH)-1:0] write_result_1;
    wire write_valid_1;
    
    Mul_Core
    #(
        .IN_DATA_WIDTH(IN_DATA_WIDTH)
    ) u_mul_core_8b_0(
        .clk(clk),
        .reset_n(reset_n),
        .i_valid(r_valid),
        .i_a(write_A_0),
        .i_b(write_B_0),
        .o_result(write_result_0),
        .o_valid(write_valid_0)
    );
    
    Mul_Core
    #(
        .IN_DATA_WIDTH(IN_DATA_WIDTH)
    ) u_mul_core_8b_1(
        .clk(clk),
        .reset_n(reset_n),
        .i_valid(r_valid),
        .i_a(write_A_1),
        .i_b(write_B_1),
        .o_result(write_result_1),
        .o_valid(write_valid_1)
    );

    
    wire result_valid = write_valid_0 & write_valid_1;
    wire [(4*IN_DATA_WIDTH)-1:0] result_value = {write_result_1, write_result_0};
    
    assign addr_b1 = addr_cnt_write;
    assign ce_b1 = result_valid;
    assign we_b1 = result_valid;
    assign d0_b1 = result_value;
   
endmodule
