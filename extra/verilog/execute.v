/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (conditions, ReadData_s, ReadData_t, imme, addr_em, ReadData_t_em, data_m2m, mem_stall,
                pass_next, imme_next, data_e2e, pc_2, pc_2_next, m2m_sel_dff, clk, rst, err_de, err);

   
   output [15:0] addr_em, data_e2e;
   output [15:0] pc_2_next, ReadData_t_em, imme_next;
   output [8:0] pass_next;
   output err;
   /*
   0 = St_sel;
   1 = Ld_sel;
   2 = halt;
   3-4 = wb_sel;
   5 = reg_write (enable)
   6-8 = wb_sel
   */
   input [15:0] imme, ReadData_t, ReadData_s, pc_2, data_m2m;
   input [18:0] conditions;
   input clk, rst, mem_stall;
   input m2m_sel_dff, err_de;
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
   wire [15:0] result, data_in;

   // m2m forward
   assign data_in = m2m_sel_dff? data_m2m : ReadData_t;
   // e2e forward
   //assign 
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

   mux4_1 wb_select[15:0](.InA(pc_2), .InB(16'h0), .InC(imme), 
                    .InD(result), .S(conditions[14:13]), .Out(data_e2e)); 
   // btr
   BTR btr (.data(ReadData_s), .result(BTR_res));

   // pipeline stage
   // dff conditions_ff [18:0] (.d(conditions_pre), .clk(clk), .rst(rst), .q(conditions));
   // dff imme_ff [15:0] (.d(imme_pre), .clk(clk), .rst(rst), .q(imme));
   // dff ReadData_t_ff [15:0] (.d(ReadData_t_pre), .clk(clk), .rst(rst), .q(ReadData_t));
   // dff ReadData_s_ff [15:0] (.d(ReadData_s_pre), .clk(clk), .rst(rst), .q(ReadData_s));
   // dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
   
   //wire [15:0] pc_2, ReadData_t, imme_next;

   

   single_reg data_ff (.writeData(data_in), .clk(clk), .rst(rst), .readData(ReadData_t_em), .writeEn(~mem_stall));
   single_reg #(9) pass_ff (.writeData(pass), .clk(clk), .rst(rst), .readData(pass_next), .writeEn(~mem_stall));
   single_reg addr_ff (.writeData(result), .clk(clk), .rst(rst), .readData(addr_em), .writeEn(~mem_stall));
   single_reg pc_2_ff (.writeData(pc_2), .clk(clk), .rst(rst), .readData(pc_2_next), .writeEn(~mem_stall));
   single_reg imme_ff (.writeData(imme), .clk(clk), .rst(rst), .readData(imme_next), .writeEn(~mem_stall));
   single_reg #(1) err_ff (.writeData(err_de), .clk(clk), .rst(rst), .readData(err), .writeEn(~mem_stall));
endmodule
