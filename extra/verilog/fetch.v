/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (pc, pc_next, clk, rst, instr, halt, branch, pc_2, pc_change, haz_stall, branch_taken, mem_stall, instr_stall, err);

    // TODO: Your code here
    output wire [15:0] instr;
    output [15:0] pc, pc_2;
    output instr_stall, err;
    input [15:0] pc_next;
    input clk;
    input rst;
    input halt, haz_stall, mem_stall;
    input pc_change; // input signal indicates a new pc other than pc+2 is occured
    input branch_taken;
    input branch_decode;

    wire enable, valid_in, err_f;
    wire [15:0] pc, newPc, pc_2_pre, pc_pred, PC_raw, instr_raw, instr_pre, signed_imm;

    wire predict_taken, branch, predict_taken_ff;

    assign enable = ~halt;
    assign newPc = ((branch_taken != predict_taken_ff) & branch_decode) ?
                  (branch_taken ? pc_next : pc_2) :
                  (predict_taken ? pc_pred : pc_2_pre);
    assign instr_pre = (branch_taken|(~valid_in)) ? 16'h0800 : instr_raw; 
    
    single_reg pc_register (.readData(PC_raw), .clk(clk), .rst(rst), .writeData(newPc), .writeEn((~haz_stall) & (~(instr_stall|mem_stall))));  
    //memory2c instr_file (.data_out(instr_raw), .data_in(16'h0), .addr(PC_raw), .enable(enable), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
    cla_16b inc_2(.A(PC_raw), .B(16'h0002), .C_in(1'b0), .S(pc_2_pre), .C_out());
    mem_system instr_file(.DataOut(instr_raw), .Done(valid_in), .Stall(instr_stall), .CacheHit(), 
                        .err(err_f), .Addr(PC_raw), .DataIn(16'h0), .Rd(1'b1), .Wr(1'b0), .createdump(1'b0), 
                        .clk(clk), .rst(rst));

   cla_16b p_br(.A(pc_2_pre), .B(signed_imm), .C_in(1'b0), .S(pc_pred), .C_out())
   assign signed_imm = {{8{instr_pre[7]}},{instr_pre[7:0]}};
   assign branch = (instr[15:13] == 3'b011);
   single_reg #(1) br(.writeData(branch_taken)), .clk(clk), .rst(rst), .readData(predict_taken), .writeEn(branch_decode & (~haz_stall) & (~(instr_stall|mem_stall))));
   dff p_t(.q(predict_taken_ff), d(predict_taken), .clk(clk), .rst(rst))
    // pipeline registers
   //dff pc_in_ff [15:0] (.d(PC_raw), .clk(clk), .rst(rst), .q(pc));
   single_reg pc_in_ff (.writeData(PC_raw), .clk(clk), .rst(rst), .readData(pc), .writeEn((~haz_stall) & (~(instr_stall|mem_stall))));
   single_reg instruction (.writeData(instr_pre), .clk(clk), .rst(rst), .readData(instr), .writeEn((~haz_stall) & (~(instr_stall|mem_stall))));
   //dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
   single_reg pc_2_ff (.writeData(pc_2_pre), .clk(clk), .rst(rst), .readData(pc_2), .writeEn((~haz_stall) & (~(instr_stall|mem_stall))));
   single_reg #(1)err_ff (.writeData(err_f), .clk(clk), .rst(rst), .readData(err), .writeEn((~haz_stall) & (~(instr_stall|mem_stall))));
endmodule
