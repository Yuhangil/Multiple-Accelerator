`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 19:37:59
// Design Name: 
// Module Name: Mul_Core
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


module Mul_Core
#(
    parameter IN_DATA_WIDTH = 8    
)
(
    input clk,
    input reset_n,
    input i_valid,
    input [IN_DATA_WIDTH-1:0] i_a,
    input [IN_DATA_WIDTH-1:0] i_b,
    output o_valid,
    output [(2*IN_DATA_WIDTH)-1:0] o_result   
);

    reg r_valid;
    reg [(2*IN_DATA_WIDTH)-1:0] read_result;
    wire [(2*IN_DATA_WIDTH)-1:0] write_result;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_valid <= 1'b0;
        end else begin
            r_valid <= i_valid;
        end
    end
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            read_result <= {(2*IN_DATA_WIDTH){1'b0}};
        end else begin
            read_result <= write_result;
        end
    end
    
    assign o_valid = r_valid;
    assign write_result = i_a * i_b;
    assign o_result = read_result;
    
    
endmodule
