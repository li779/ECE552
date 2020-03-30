/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (conditions, ReadData_s, ReadData_t, imme, addr_em, ReadData_t_em, pass_next, imme_next, pc_2, pc_2_next, clk, rst);

   
   output [15:0] addr_em;
   output [15:0] pc_2_next, ReadData_t_em, imme_next;
   output [8:0] pass_next;
   /*
   0 = St_sel;
   1 = Ld_sel;
   2 = halt;
   3-4 = wb_sel;
   5 = reg_write (enable)
   6-8 = wb_sel
   */
   input [15:0] imme, ReadData_t, ReadData_s, pc_2;
   input [18:0] conditions;
   input clk, rst;
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
   wire[18:0] conditions;
   wire[15:0] ReadData_s;
   
   
   wire [15:0] flag_res, Out, InB, BTR_res;
   wire Cin, invB;
   wire [2:0] Op;
   wire Zero, Ofl, less;
   wire [1:0] Alu_ops;
   wire Result_sel, MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel;

   wire [8:0] pass;
   wire [15:0] result;

   // conditions assign
   assign MemOp_sel = conditions[0];
   assign BTR_sel = conditions[1];
   assign SLBI_sel = conditions[2];
   assign Imme_sel = conditions[3];
   assign Shft_sel = conditions[4];
   assign Alu_sel = conditions[5];
   assign Result_sel = conditions[6];
   assign Alu_ops = conditions[12:11];
   

   assign pass[0] = conditions[8];
   assign pass[1] = conditions[9];
   assign pass[2] = conditions[10];
   assign pass[4:3] = conditions[14:13];
   assign pass[5] = conditions[15];
   assign pass[8:6] = conditions[18:16];

   alu alu1 (.InA(ReadData_s), .InB(InB), .Cin(Cin), .Op(Op), .invA(Cin), .invB(invB), .sign(1'b1), .Out(Out), .Zero(Zero), .Ofl(Ofl), .C_out(C_out));
   //cla_4b adder (A, B, C_in, S, C_out, G_out, P_out);

   assign InB = Imme_sel ? imme : ReadData_t;
   assign Cin = (Result_sel & ~(Alu_ops == 2'b11)) | (Alu_sel & (Alu_ops == 2'b01) & (~MemOp_sel));
   assign invB = (Alu_sel & Alu_ops == 2'b11 & (~MemOp_sel) & (~(Result_sel & (Alu_ops == 2'b11)))) | (Shft_sel & Alu_ops == 2'b10);
   assign Op = (MemOp_sel | Result_sel) ? {Alu_sel, 2'b00} : {Alu_sel, Alu_ops};

   // flag bit logic
   assign less = ~Zero & (Out[15]==Ofl);
   assign flag_res = (Alu_ops == 2'b00) ? {{15{1'b0}}, Zero} : 
                     (Alu_ops == 2'b01) ? {{15{1'b0}}, less} :
                     (Alu_ops == 2'b10) ? {{15{1'b0}}, less|Zero} :
                     {{15{1'b0}}, C_out};

   assign result = ({Result_sel, BTR_sel, SLBI_sel} == 3'b100) ? flag_res : 
                   ({Result_sel, BTR_sel, SLBI_sel} == 3'b000) ? Out :
                   (BTR_sel) ? BTR_res : {ReadData_s[7:0], imme[7:0]};


   // btr
   BTR btr (.data(ReadData_s), .result(BTR_res));

   // pipeline stage
   // dff conditions_ff [18:0] (.d(conditions_pre), .clk(clk), .rst(rst), .q(conditions));
   // dff imme_ff [15:0] (.d(imme_pre), .clk(clk), .rst(rst), .q(imme));
   // dff ReadData_t_ff [15:0] (.d(ReadData_t_pre), .clk(clk), .rst(rst), .q(ReadData_t));
   // dff ReadData_s_ff [15:0] (.d(ReadData_s_pre), .clk(clk), .rst(rst), .q(ReadData_s));
   // dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
   
   //wire [15:0] pc_2, ReadData_t, imme_next;

   

   dff data_ff [15:0] (.d(ReadData_t), .clk(clk), .rst(rst), .q(ReadData_t_em));
   dff pass_ff [8:0] (.d(pass), .clk(clk), .rst(rst), .q(pass_next));
   dff addr_ff [15:0] (.d(result), .clk(clk), .rst(rst), .q(addr_em));
   dff pc_2_ff [15:0] (.d(pc_2), .clk(clk), .rst(rst), .q(pc_2_next));
   dff imme_ff [15:0] (.d(imme), .clk(clk), .rst(rst), .q(imme_next));
endmodule
