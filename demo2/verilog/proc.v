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
   wire [14:0] conditions_de;
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
   */

   wire [15:0] imme_de; // immediate decode -> execute
   wire [15:0] imme_em; // immediate execute -> memory
   wire [15:0] imme_mw; // immediate mem -> wb

   wire [15:0] pc_2_de; // pc_2 decode -> execute
   wire [15:0] pc_2_em; // pc_2 execute -> memory
   wire [15:0] pc_2_mw; // pc_2 mem -> wb

   wire [4:0] pass_em;  // control sig execute -> mem
   wire [15:0] result_mw; // control sig mem -> wb
   fetch fetch0(.pc(pc), .pc_next(pc_next), .clk(clk), .rst(rst), .instr(instr), .halt(conditions_de[10]));
   decode decode0(.clk(clk), .rst(rst), .instr(instr), .err(err), .PC(pc), .newPC(pc_next), 
                .ReadData_t(ReadData_t), .ReadData_s(ReadData_s), .conditions(conditions_de),
                .WriteData_d(WriteData_d), .immed(imme_de), .pc_2(pc_2_de));
   execute execute0(.conditions_pre(conditions_de), .pass(pass_em),
                    .conditions_pre(conditions_de), .ReadData_s_pre(ReadData_s), .ReadData_t_pre(ReadData_t_de), 
                    .ReadData_t(ReadData_t_em), .imme_pre(imme_de), .result(result), imme(imme_em), .pc_2_pre(pc_2_de), .pc_2(pc_2_em));
   memory memory0(.pass_pre(pass_em), .imme_pre(imme_em), .imme(imme_mw), .addr_pre(result)
                  .data_in(ReadData_t_em), .data_out(mem_data), .result_mw(result_mw),
                  .clk(clk), .rst(rst), .pc_2_pre(pc_2_em), .pc_2(pc_2_mw), .wb_sel(wb_sel));
   wb wb0(.mem_data(mem_data), .PC_2(pc_2_mw), .ALU_data(result_mw), 
         .signEx_data(imme_mw), .wb_sel(wb_sel), .wb_out(WriteData_d));
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
