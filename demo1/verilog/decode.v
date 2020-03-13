/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, instr, err, PC, newPC, MemOp_sel, 
               BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel,
               wb_sel, Alu_ops, Result_sel,  
               ReadData_t, ReadData_s, WriteData_d, immed, St_sel, Ld_sel, halt, pc_2);

   // TODO: Your code here
   input [15:0] instr, PC, WriteData_d, pc_2;
   input rst, clk;
   output [1:0] Alu_ops, wb_sel;
   output MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel, 
          Result_sel, err, St_sel, Ld_sel;
   output [15:0] newPC, ReadData_s, ReadData_t, immed;
   output halt;
   
   wire [2:0] Rs, Rt, Rd, Reg2Sel;
   wire [15:0] PC, newPC;
   wire Reg_write, jump, branch, regRead;
   reg [2:0] wr_sel;
   wire[1:0] branch_cond;
   wire halt;
    wire halt_in;

    dff flops (.d(halt_in), .clk(clk), .rst(rst), .q(halt));
   
   always@(instr)
   casex(instr[15:11])
      5'b1001x: wr_sel = Rs;
      5'b11000: wr_sel = Rs;
      5'b0011x: wr_sel = 3'b111;  
      default : wr_sel = Rd;   
   endcase
   assign Reg2Sel = (MemOp_sel & ~(instr[12:11] == 2'b01)) ? Rd : Rt;

   PC pc(.pc(PC), .halt(halt), .newPC(newPC), .Rs_data(ReadData_s), 
         .Sign_imm(immed), .jump(jump), .branch(branch), 
         .regRead(regRead), .pc_2(pc_2), .branch_cond(branch_cond));
   immediate sign_Extend(.instr(instr), .immed(immed));
   regFile regFile0(.read1Data(ReadData_s), .read2Data(ReadData_t), 
                           .err(err), .clk(clk), .rst(rst), 
                           .read1RegSel(Rs), .read2RegSel(Reg2Sel), 
                           .writeRegSel(wr_sel), .writeData(WriteData_d), 
                           .writeEn(Reg_write));
   decode_instr decoder(.instr(instr), .Alu_ops(Alu_ops), 
                        .Result_sel(Result_sel), .MemOp_sel(MemOp_sel), 
                        .BTR_sel(BTR_sel), .SLBI_sel(SLBI_sel), 
                        .Imme_sel(Imme_sel), .Shft_sel(Shft_sel), 
                        .Alu_sel(Alu_sel), .Rs(Rs), .Rt(Rt), .Rd(Rd), 
                        .jump(jump), .branch(branch), .regRead(regRead), .Reg_write(Reg_write),
                        .wb_sel(wb_sel), .St_sel(St_sel), .Ld_sel(Ld_sel), .halt(halt_in), .branch_cond(branch_cond));

endmodule
