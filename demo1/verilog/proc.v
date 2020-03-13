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
   wire [15:0] ReadData_t, ReadData_s, WriteData_d, imme, result;
   wire Alu_sel, MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Result_sel, halt;
   wire [1:0] wb_sel;

   fetch fetch0(.pc(pc), .pc_next(pc_next), .clk(clk), .rst(rst), .instr(instr), .halt(halt));
   decode decode0(.clk(clk), .rst(rst), .instr(instr), .err(err), .PC(pc), .newPC(pc_next), .MemOp_sel(MemOp_sel), 
               .BTR_sel(BTR_sel), .SLBI_sel(SLBI_sel), .Imme_sel(Imme_sel), .Shft_sel(Shft_sel), .Alu_sel(Alu_sel), 
               .wb_sel(wb_sel), .Alu_ops(Alu_ops), .Result_sel(Result_sel), .ReadData_t(ReadData_t), .ReadData_s(ReadData_s),
                .WriteData_d(WriteData_d), .immed(imme), .St_sel(St_sel), .Ld_sel(Ld_sel), .halt(halt), .pc_2(pc_2));
   execute execute0(.Alu_ops(Alu_ops), .Alu_sel(Alu_sel), .Shft_sel(Shft_sel), .Result_sel(Result_sel), .MemOp_sel(MemOp_sel), .BTR_sel(BTR_sel),
    .SLBI_sel(SLBI_sel), .ReadData_s(ReadData_s), .ReadData_t(ReadData_t), .Imme_sel(Imme_sel), .imme(imme), .result(result));
   memory memory0(.halt(halt), .data_in(ReadData_t), .data_out(mem_data), .addr(result), .memRead(Ld_sel), .memWrite(St_sel), .clk(clk), .rst(rst));
   wb wb0(.mem_data(mem_data), .PC_2(pc_2), .ALU_data(result), 
         .signEx_data(imme), .wb_sel(wb_sel), .wb_out(WriteData_d));
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
