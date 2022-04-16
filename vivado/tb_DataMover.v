`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 20:16:54
// Design Name: 
// Module Name: tb_DataMover
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

`define CNT 31
`define ADDR_WIDTH 12
`define DATA_WIDTH 32
`define MEM_DEPTH 4096
`define IN_DATA_WIDTH 8
`define NUM_CORE 2

module tb_DataMover
(
);

    reg clk, reset_n;
    reg i_run;
    reg [`CNT-1:0] i_num_cnt;
    wire o_idle;
    wire o_write;
    wire o_read;
    wire o_done;
    
    // Memory I/F
    
    wire [`ADDR_WIDTH-1:0] addr0_b0;
    wire ce0_b0;
    wire we0_b0;
    wire [`DATA_WIDTH-1:0] q0_b0;
    wire [`DATA_WIDTH-1:0] d0_b0;
    
    wire [`ADDR_WIDTH-1:0] addr0_b1;
    wire ce0_b1;
    wire we0_b1;
    wire [`DATA_WIDTH-1:0] q0_b1;
    wire [`DATA_WIDTH-1:0] d0_b1;
    
    // Bram0
    reg [`ADDR_WIDTH-1:0] addr1_b0;
    reg ce1_b0;
    reg we1_b0;
    wire [`DATA_WIDTH-1:0] q1_b0;
    reg [`DATA_WIDTH-1:0] d1_b0;
    
    
    // bram 1 
    reg [`ADDR_WIDTH-1:0] addr1_b1;
    reg ce1_b1;
    reg we1_b1;
    wire [`DATA_WIDTH-1:0] q1_b1;
    reg [`DATA_WIDTH-1:0] d1_b1;
    
    
    
    reg [`IN_DATA_WIDTH-1:0] a0;
    reg [`IN_DATA_WIDTH-1:0] b0;
    reg [`IN_DATA_WIDTH-1:0] a1;
    reg [`IN_DATA_WIDTH-1:0] b1;
    
    always
        #5 clk = ~clk;
    
    integer i, f_in, f_out, status;
    reg [(`DATA_WIDTH/`NUM_CORE)-1:0] result_0;
    reg [(`DATA_WIDTH/`NUM_CORE)-1:0] result_1;
    
    initial begin
        f_in = $fopen("ref_c_rand_input.txt", "rb");
        f_out =$fopen("rtl_result.txt", "wb");
    end
    
    initial begin
        $display("initialize value [%0d]", $time);
        reset_n = 1;
        clk = 0;
        i_run = 0;
        i_num_cnt = `MEM_DEPTH;
        
        addr1_b0 = 0;
        ce1_b0 = 0;
        we1_b0 = 0;
        d1_b0 = 0;
        
        addr1_b1 = 0;
        ce1_b1 = 0;
        we1_b1 = 0;
        d1_b1 = 0;
        
        $display("Reset[%0d]", $time);
        #100
        reset_n = 0;
        #10
        reset_n = 1;
        #10
        @(posedge clk);
    
        $display("Mem write to Bram0[%0d]", $time);
        for(i=0;i < i_num_cnt;i=i+1) begin
            status = $fscanf(f_in, "%d %d %d %d \n", a0, b0, a1, b1);
            u_TDPBRAM_0.ram[i] = {a0, b0, a1, b1};
        end
        
        $display("Check Idle[%0d]", $time);
        wait(o_idle);
        
        $display("Data Mover[%0d]", $time);
        i_run = 1;
        @(posedge clk);
        i_run = 0;
        
        $display("Wait Done[%0d]", $time);
        wait(o_done);
        
        $display("Mem read from Bram1[%0d]", $time);
        
        for(i=0; i < i_num_cnt; i=i+1) begin
            {result_0, result_1} = u_TDPBRAM_1.ram[i];
            $fwrite(f_out, "%0d %0d \n", result_0, result_1);
        end
        
        $fclose(f_in);
        $fclose(f_out);
        #100
        $display("Success");
        $finish;
    end
    
    DataMover
    #(
        .CNT (`CNT),
        .DWIDTH (`DATA_WIDTH),
        .AWIDTH (`ADDR_WIDTH),
        .MEM_SIZE (`MEM_DEPTH),
        .IN_DATA_WIDTH (`IN_DATA_WIDTH)
    ) u_DataMover (
        .clk        (clk),
        .reset_n    (reset_n),
        .i_run      (i_run),
        .i_num_cnt  (i_num_cnt),
        .o_idle     (o_idle),
        .o_read     (o_read),
        .o_write    (o_write),
        .o_done     (o_done),
     
     // bram 0   
    .addr_b0        (addr0_b0),
    .ce_b0          (ce0_b0),
    .we_b0          (we0_b0),
    .q0_b0          (q0_b0),
    .d0_b0          (d0_b0),
    
    // (Bram1)
    .addr_b1        (addr0_b1),
    .ce_b1          (ce0_b1),
    .we_b1          (we0_b1),
    .q0_b1          (q0_b1),
    .d0_b1          (d0_b1)
        
    );
    
    Bram1
    #(
        .DWIDTH (`DATA_WIDTH),
        .AWIDTH (`ADDR_WIDTH),
        .MEM_SIZE (`MEM_DEPTH)
    ) u_TDPBRAM_0(
        .clk(clk),
        
        .addr0 (addr0_b0),
        .ce0 (ce0_b0),
        .we0 (we0_b0),
        .q0 (q0_b0),
        .d0 (d0_b0),
        
        .addr1 (addr1_b0),
        .ce1 (ce1_b0),
        .we1 (we1_b0),
        .q1 (q1_b0),
        .d1 (d1_b0)
    );
    
    Bram1
    #(
        .DWIDTH (`DATA_WIDTH),
        .AWIDTH (`ADDR_WIDTH),
        .MEM_SIZE (`MEM_DEPTH)
    ) u_TDPBRAM_1(
        .clk(clk),
        
        .addr0 (addr0_b1),
        .ce0 (ce0_b1),
        .we0 (we0_b1),
        .q0 (q0_b1),
        .d0 (d0_b1),
        
        .addr1 (addr1_b1),
        .ce1 (ce1_b1),
        .we1 (we1_b1),
        .q1 (q1_b1),
        .d1 (d1_b1)
    );
endmodule
