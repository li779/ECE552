/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, instr, err, PC, newPC, conditions,  
               ReadData_t, ReadData_s, WriteData_d, immed, pc_2);

   // TODO: Your code here
   input [15:0] instr, PC, WriteData_d;
   input rst, clk;
   output [15:0] newPC, ReadData_s, ReadData_t, immed, pc_2;
   output [14:0] conditions;
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
   reg [15:0] instr_pip, PC_pip, WriteData_d_pip;
   wire [1:0] Alu_ops, wb_sel;
   wire MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel, 
          Result_sel, err, St_sel, Ld_sel, halt;
   wire [2:0] Rs, Rt, Rd, Reg2Sel;
   wire [15:0] newPC;
   wire Reg_write, jump, branch, regRead;
   reg [2:0] wr_sel;
   wire[1:0] branch_cond;
   wire halt;
   wire halt_in;

   dff flops (.d(halt_in), .clk(clk), .rst(rst), .q(halt));

   // conditions assign
   assign conditions[0] = MemOp_sel;
   assign conditions[1] = BTR_sel;
   assign conditions[2] = SLBI_sel;
   assign conditions[3] = Imme_sel;
   assign conditions[4] = Shft_sel;
   assign conditions[5] = Alu_sel;
   assign conditions[6] = Result_sel;
   assign conditions[7] = err;
   assign conditions[8] = St_sel;
   assign conditions[9] = Ld_sel;
   assign conditions[10] = halt;
   assign conditions[11:12] = Alu_ops;
   assign conditions[13:14] = wb_sel;
   
   always@(instr_pip)
   casex(instr_pip[15:11])
      5'b1001x: wr_sel = Rs;
      5'b11000: wr_sel = Rs;
      5'b0011x: wr_sel = 3'b111;  
      default : wr_sel = Rd;   
   endcase
   assign Reg2Sel = (MemOp_sel & ~(instr_pip[12:11] == 2'b01)) ? Rd : Rt;

   PC pc(.pc(PC_pip), .halt(halt), .newPC(newPC), .Rs_data(ReadData_s), 
         .Sign_imm(immed), .jump(jump), .branch(branch), 
         .regRead(regRead), .pc_2(pc_2), .branch_cond(branch_cond));
   immediate sign_Extend(.instr(instr_pip), .immed(immed));
   regFile regFile0(.read1Data(ReadData_s), .read2Data(ReadData_t), 
                           .err(err), .clk(clk), .rst(rst), 
                           .read1RegSel(Rs), .read2RegSel(Reg2Sel), 
                           .writeRegSel(wr_sel), .writeData(WriteData_d_pip), 
                           .writeEn(Reg_write));
   decode_instr decoder(.instr(instr_pip), .Alu_ops(Alu_ops), 
                        .Result_sel(Result_sel), .MemOp_sel(MemOp_sel), 
                        .BTR_sel(BTR_sel), .SLBI_sel(SLBI_sel), 
                        .Imme_sel(Imme_sel), .Shft_sel(Shft_sel), 
                        .Alu_sel(Alu_sel), .Rs(Rs), .Rt(Rt), .Rd(Rd), 
                        .jump(jump), .branch(branch), .regRead(regRead), .Reg_write(Reg_write),
                        .wb_sel(wb_sel), .St_sel(St_sel), .Ld_sel(Ld_sel), .halt(halt_in), .branch_cond(branch_cond));



   // pipeline registers
   dff data_in [15:0] (.d(WriteData_d), .clk(clk), .rst(rst), .q(WriteData_d_pip));
   dff pc_in [15:0] (.d(PC), .clk(clk), .rst(rst), .q(PC_pip));
   dff instruction [15:0] (.d(instr), .clk(clk), .rst(rst), .q(instr_pip));

endmodule
