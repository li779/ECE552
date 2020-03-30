/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (pc, pc_next, clk, rst, instr, halt, pc_2, pc_change, haz_stall);

    // TODO: Your code here
    output wire [15:0] instr;
    output [15:0] pc, pc_2;
    input [15:0] pc_next;
    input clk;
    input rst;
    input halt, haz_stall;
    input pc_change; // input signal indicates a new pc other than pc+2 is occured

    wire enable;
    wire [15:0] pc, newPc, pc_in, pc_2_pre, PC_raw, instr_raw;
    assign enable = ~halt;
    assign newPc = pc_change ? pc_next : pc_2;
    // assign pc_in = haz_stall ? pc : newPc;  //FIXME
    
    single_reg pc_register ( .readData(pc_raw), .clk(clk), .rst(rst), .writeData(pc_in), .writeEn(1'b1));  
    memory2c instr_file (.data_out(instr_raw), .data_in(16'h0), .addr(pc), .enable(enable), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
    cla_16b inc_2(.A(pc), .B(16'h0002), .C_in(1'b0), .S(pc_2_pre), .C_out());

    // pipeline registers
   dff pc_in [15:0] (.d(PC_raw), .clk(clk), .rst(rst), .q(pc));
   dff instruction [15:0] (.d(instr_raw), .clk(clk), .rst(rst), .q(instr));
   dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
endmodule
