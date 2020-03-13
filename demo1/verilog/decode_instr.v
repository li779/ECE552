/*
   CS/ECE 552 Spring '20
  
   Filename        : decode_instr.v
   Description     : This is the module for decoding instruction.
*/
module decode_instr (instr, Alu_ops, Result_sel, MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel, Rs, Rt, Rd, jump, branch, regRead, Reg_write, wb_sel, St_sel, Ld_sel, halt, branch_cond);

    //output J_type, I1_type, I2_type, R_type; // J: jump; I1: imme alu; I2: pc, R: 3_reg
    //output exten_type; // 0: zero-extend; 1: sign-extend
    output [2:0] Rs, Rt, Rd;
    output [1:0] Alu_ops, wb_sel, branch_cond;
    output Result_sel; // 0: from alu, 1: from flag bit
    output MemOp_sel, BTR_sel, SLBI_sel, Imme_sel, Shft_sel, Alu_sel, jump, branch, regRead, Reg_write, St_sel, Ld_sel, halt;
    input [15:0] instr;

    wire NOP, I1_type;
    // decode instruction type
    //assign exten_type = ~((instr[15:12] == 4'b0101) || (instr[15:11] == 5'b10010));
    //assign J_type = (instr[15:13] == 3'b001);
    assign I1_type = (instr[15:13] == 3'b010) || (instr[15:13] == 3'b101) || 
                         (instr[15:13] == 3'b100) && ~(instr == 5'b10010);
    //assign I2_type = (instr[15:13] == 3'b011) || (instr[15:11] == 5'b11000) 
                      //|| (instr[15:11] == 5'b10010);
    //assign R_type = (instr[15:14] == 2'b11) && ~(instr == 5'b11000);

    // register selection signal
    assign Rs = instr[10:8];
    assign Rt = instr[7:5];
    assign Rd = I1_type ? Rt : instr[4:2];

    // Alu op 
    assign Alu_ops = (instr[15:13] == 3'b110) ? instr[1:0] : instr[12:11];
    assign Result_sel = &instr[15:13];
    assign BTR_sel = (instr[15:11] == 5'b11001);
    assign SLBI_sel = (instr[15:11] == 5'b10010);
    assign Imme_sel = (^instr[15:14]) | (instr[15:11] == 5'b11000);
    assign Shft_sel = (instr[15:13] == 3'b101) | (instr[15:11] == 5'b11010);
    assign Alu_sel = (instr[15:13] == 3'b010) | (instr[15:11] == 5'b11011) | MemOp_sel | (instr[15:13] == 3'b111);

    // store
    assign MemOp_sel = St_sel | Ld_sel;
    assign St_sel = (instr[15:11] == 5'b10000) | (instr[15:11] == 5'b10011) & ~NOP & ~halt;
    assign Ld_sel = (instr[15:11] == 5'b10001);

    // jump
    assign jump = (instr[15:13] == 3'b001);
    assign branch = (instr[15:13] == 3'b011);
    assign regRead = instr[11];
    assign branch_cond = instr[12:11];

    // regwrite
    assign Reg_write = ~(instr[15:11] == 5'b10000 | branch | instr[15:12] == 4'b0010 | instr[15:13] == 3'b000) & ~NOP & ~halt;

    //wb
    assign wb_sel = (instr[15:12] == 4'b0011) ? 2'b00 : 
                    (instr[15:11] == 5'b10001) ? 2'b01 :
                    (instr[15:11] == 5'b11000) ? 2'b10 : 2'b11;
    // NOP and halt
    assign halt = ~(|instr[15:11]);
    assign NOP = (instr[15:11] == 5'b00001);

endmodule