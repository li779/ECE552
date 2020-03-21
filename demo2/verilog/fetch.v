/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (pc, pc_next, clk, rst, instr, halt);

    // TODO: Your code here
    output wire [15:0] instr;
    output [15:0] pc;
    input [15:0] pc_next;
    input clk;
    input rst;
    input halt;

    wire enable;
    wire [15:0] pc;
    assign enable = ~halt;
    
    single_reg pc_register ( .readData(pc), .clk(clk), .rst(rst), .writeData(pc_next), .writeEn(1'b1));  
    memory2c instr_file (.data_out(instr), .data_in(16'h0), .addr(pc), .enable(enable), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
endmodule
