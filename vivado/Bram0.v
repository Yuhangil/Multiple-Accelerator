`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 17:22:37
// Design Name: 
// Module Name: Bram0
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


module Bram0(
    clk,
    addr0,
    ce0,
    we0,
    q0,
    d0,
    addr1,
    ce1,
    we1,
    q1,
    d1,
    );
    
    parameter DWIDTH = 8;
    parameter AWIDTH = 12;
    parameter MEM_SIZE = 3840;
    
    input clk;
    
    input [AWIDTH-1:0] addr0;
    input ce0;
    input we0;
    input [DWIDTH-1:0] d0;
    output reg [DWIDTH-1:0] q0;
    
    input [AWIDTH-1:0] addr1;
    input ce1;
    input we1;
    input [DWIDTH-1:0] d1;
    output reg [DWIDTH-1:0] q1;
    
    (* ram_style = "block"*) reg [DWIDTH-1:0] ram [0:MEM_SIZE-1];
    
    always@(posedge clk) begin
        if(ce0) begin
            if(we0) begin
                ram[addr0] <= d0;
            end else begin
                q0 <= ram[addr0];
            end
        end
    end
    
    always@(posedge clk) begin
        if(ce1) begin
            if(we1) begin
                ram[addr1] <= d1;
            end else begin
                q1 <= ram[addr1];
            end
        end
    end
    
endmodule
