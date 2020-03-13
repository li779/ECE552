/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (halt, data_in, data_out, addr, memRead, memWrite, clk, rst);

    // TODO: Your code here
    output [15:0] data_out;
    input [15:0] data_in;
    input [15:0] addr;
    input memWrite;
    input memRead;
    input clk;
    input rst, halt;

    memory2c memory_file (.data_out(data_out), .data_in(data_in), .addr(addr), .enable((memRead|memWrite)&(~halt)), .wr(memWrite), .createdump(halt), .clk(clk), .rst(rst));
   
endmodule
