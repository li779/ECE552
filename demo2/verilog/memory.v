/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (pass_pre, imme_pre, imme, data_in, data_out, addr_pre, clk, rst, pc_2_pre, pc_2, wb_sel, result_mw);

    // TODO: Your code here
    output [15:0] data_out, wb_sel;
    output reg [15:0] pc_2, imme, result_mw;
    input [15:0] data_in, imme_pre, pc_2_pre;
    input [15:0] addr_pre;
    input clk;
    input rst;
    input [4:0] pass_pre;
    /*
   0 = St_sel;
   1 = Ld_sel;
   2 = halt;
   3-4 = wb_sel;
   */

    reg[15:0] data;
    reg[5:0] pass;
    wire halt, memRead, memWrite;

    assign memRead = pass[1];
    assign memWrite = pass[0];
    assign halt = pass[2];
    assign wb_sel = pass[3:4];

    memory2c memory_file (.data_out(data_out), .data_in(data), .addr(result_mw), .enable((memRead|memWrite)&(~halt)), .wr(memWrite), .createdump(halt), .clk(clk), .rst(rst));
   
    // pipeline stage
    dff data [15:0] (.d(data_in), .clk(clk), .rst(rst), .q(data));
    dff pass_ff [4:0] (.d(pass_pre), .clk(clk), .rst(rst), .q(pass));
    dff addr_ff [15:0] (.d(addr_pre), .clk(clk), .rst(rst), .q(result_mw));
    dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
    dff imme_ff [15:0] (.d(imme_pre), .clk(clk), .rst(rst), .q(imme));

endmodule
