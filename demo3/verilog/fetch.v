/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (pc, pc_next, clk, rst, instr, halt, pc_2, pc_change, haz_stall, branch_taken);

    // TODO: Your code here
    output wire [15:0] instr;
    output [15:0] pc, pc_2;
    input [15:0] pc_next;
    input clk;
    input rst;
    input halt, haz_stall;
    input pc_change; // input signal indicates a new pc other than pc+2 is occured
    input branch_taken;

    wire enable;
    wire [15:0] pc, newPc, pc_2_pre, PC_raw, instr_raw, instr_pre;
    assign enable = ~halt;
    assign newPc = branch_taken ? pc_next : pc_2_pre;
    assign instr_pre = branch_taken ? 16'h0800 : instr_raw; 
    
    single_reg pc_register ( .readData(PC_raw), .clk(clk), .rst(rst), .writeData(newPc), .writeEn(~haz_stall));  
    memory2c instr_file (.data_out(instr_raw), .data_in(16'h0), .addr(PC_raw), .enable(enable), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
    cla_16b inc_2(.A(PC_raw), .B(16'h0002), .C_in(1'b0), .S(pc_2_pre), .C_out());

    // pipeline registers
   //dff pc_in_ff [15:0] (.d(PC_raw), .clk(clk), .rst(rst), .q(pc));
   single_reg pc_in_ff (.writeData(PC_raw), .clk(clk), .rst(rst), .readData(pc), .writeEn(~haz_stall));
   single_reg instruction (.writeData(instr_pre), .clk(clk), .rst(rst), .readData(instr), .writeEn(~haz_stall));
   //dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
   single_reg pc_2_ff (.writeData(pc_2_pre), .clk(clk), .rst(rst), .readData(pc_2), .writeEn(~haz_stall));
endmodule
