/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (Alu_ops, Alu_sel, Shft_sel, Result_sel, MemOp_sel, BTR_sel, SLBI_sel, ReadData_s, ReadData_t, Imme_sel, imme, result);

   
   output [15:0] result;
   input [1:0] Alu_ops;
   input Result_sel, MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel;
   input [15:0] imme, ReadData_t, ReadData_s;

   
   wire [15:0] flag_res, Out, InB, BTR_res;
   wire Cin, invB;
   wire [2:0] Op;
   wire Zero, Ofl, less;

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
   
endmodule
