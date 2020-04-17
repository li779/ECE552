/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   wire [15:0] pc, pc_next, instr, mem_data, ALU_data, signEx_data, pc_2;
   wire [1:0] Alu_ops;
   wire [15:0] ReadData_t_de, ReadData_t_em, ReadData_s, WriteData_d, imme, result;
   wire Alu_sel, MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Result_sel, halt;
   wire [1:0] wb_sel;
   wire [18:0] conditions_de;
  /* conditions is a group of all conditions that output from decode stage and carry all the way through pipeline
      conditions map:
      0: MemOp_sel
      1: BTR_sel
      2: SLBI_sel
      3: Imme_sel
      4: Shft_sel
      5: Alu_sel
      6: Result_sel
      7: err
      8: St_sel
      9: Ld_sel
      10: halt
      11-12: Alu_ops
      13-14: wb_sel
      15 : Reg_write
      16-18: wr_sel
   */
   assign err = conditions_de[7];

   wire [15:0] imme_de; // immediate decode -> execute
   wire [15:0] imme_em; // immediate execute -> memory
   wire [15:0] imme_mw; // immediate mem -> wb

   wire [15:0] pc_2_fd; // pc_2 fetch -> decode
   wire [15:0] pc_2_de; // pc_2 decode -> execute
   wire [15:0] pc_2_em; // pc_2 execute -> memory
   wire [15:0] pc_2_mw; // pc_2 mem -> wb
   wire pc_change;      // is new pc pc+2

   wire [8:0] pass_em;  // control sig execute -> mem
    /*
   0 = St_sel;
   1 = Ld_sel;
   2 = halt;
   3-4 = wb_sel;
   5 = reg_write (enable)
   6-8 = wr_sel
   */
   wire [15:0] result_mw; // control sig mem -> wb

   wire Reg_write_wd;  // reg_write enable wb -> decode
   wire Reg_write_mw;  // reg_write enable memory -> wb
   // signals for harard unit
   wire haz_stall;
   wire jump, regRead, R_type, exceptions, branch_taken;

   wire [2:0] Reg_d_sel_wd;
   wire [2:0] Reg_d_sel_mw;
   wire [2:0] Rs, Reg2Sel;

   //assign haz_stall = 1'b0; //TODO

   fetch fetch0(.pc(pc), .pc_next(pc_next), .clk(clk), .rst(rst), .instr(instr), .branch_taken(branch_taken),
                .halt(conditions_de[10]), .pc_2(pc_2_fd), .pc_change(pc_change), .haz_stall(haz_stall));
   decode decode0(.clk(clk), .rst(rst), .instr(instr), .PC(pc), .newPC(pc_next), .pc_change(pc_change), .Reg_d_sel(Reg_d_sel_wd),
                .ReadData_t_next(ReadData_t_de), .ReadData_s_next(ReadData_s), .conditions_next(conditions_de), .Reg_write_wd(Reg_write_wd),
                .WriteData_d(WriteData_d), .immed_next(imme_de), .pc_2_next(pc_2_de), .pc_2_pre(pc_2_fd), .jump(jump), .regRead(regRead), 
                .R_type(R_type), .haz_stall(haz_stall), .exceptions(exceptions), .Rs(Rs), .Reg2Sel(Reg2Sel), .branch_taken(branch_taken));
   execute execute0(.conditions(conditions_de), .clk(clk), .rst(rst), .pass_next(pass_em), .ReadData_s(ReadData_s), .ReadData_t(ReadData_t_de), 
                    .ReadData_t_em(ReadData_t_em), .imme(imme_de), .addr_em(result), .imme_next(imme_em), .pc_2(pc_2_de), .pc_2_next(pc_2_em));
   memory memory0(.pass(pass_em), .clk(clk), .rst(rst), .imme(imme_em), .imme_next(imme_mw), .addr_pre(result),
                  .data_in(ReadData_t_em), .data_out(mem_data), .result_mw(result_mw), .Reg_write_wd(Reg_write_mw),
                  .pc_2(pc_2_em), .pc_2_ed(pc_2_mw), .wb_sel_ed(wb_sel), .Reg_d_sel_wd(Reg_d_sel_mw));
   wb wb0(.clk(clk), .rst(rst), .mem_data(mem_data), .PC_2(pc_2_mw), .ALU_data(result_mw), .Reg_write_mw(Reg_write_mw), .Reg_d_sel_mw(Reg_d_sel_mw),
         .signEx_data(imme_mw), .wb_sel(wb_sel), .wb_out(WriteData_d), .Reg_write_wd(Reg_write_wd), .Reg_d_sel_wd(Reg_d_sel_wd));
   hazard hazard0(.Rs(Rs), .Rt(Reg2Sel), .Rd_mem(pass_em[8:6]), .Rd_exe(conditions_de[18:16]), .Reg_wr_mem(pass_em[5]), 
                 .Reg_wr_exe(conditions_de[15]), .jump(jump), .regRead(regRead), .R_type(R_type), .Reg_haz(haz_stall), .exceptions(exceptions));
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
