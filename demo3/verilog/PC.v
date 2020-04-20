module PC(pc, halt, newPC, Rs_data, Sign_imm, jump, branch, regRead, pc_2, branch_cond, branch_taken);
    input [15:0] pc, Rs_data, Sign_imm;
    input halt; // 1 if halt (PC doesn't change)
    input [1:0] branch_cond;
    output [15:0] newPC;
    output branch_taken;
    input jump, branch, regRead;

    wire pc_base, reg_base, Rs_zero, Rs_neg;
    //wire [15:0] pc_calc; // pc before final
    wire [15:0] pc_branch; // pc for branch
    input [15:0] pc_2; // PC increment 2
    //wire [15:0] pc_fin; // PC choice between original and increment 2
    wire [15:0] pc_imm; // PC + 2 + signedImm
    wire [15:0] pc_reg; // Rs + signedImm

    // assign halt = (instr == 5'b00000) 1:0;
    assign pc_base = branch | (jump & ~regRead);
    assign reg_base = jump && regRead;

    
    //assign pc_fin = halt? pc:pc_2;
    //mux2_1 PC_inc(.InA(pc_2), .InB(pc), .S(halt), .Out(pc_fin));
    cla_16b add_imm(.A(pc_2), .B(Sign_imm), .C_in(1'b0), .S(pc_imm), .C_out());
    cla_16b add_reg(.A(Sign_imm), .B(Rs_data), .C_in(1'b0), .S(pc_reg), .C_out());

    // FIXME maybe move the register part to the ALU to reduce area

    //mux4_1_16b fin_pc(.InA(pc_fin), .InB(pc_imm), .InC(pc_reg), 
    //                  .InD(16'h0000), .S({pc_base, reg_base}), .Out(newPC));
    // assign pc_calc = pc_base ? (reg_base? 16'h0000 : pc_imm)
    //                        :(reg_base? pc_reg : pc_fin);
    assign branch_taken = (branch_cond==2'b00 & Rs_zero) | (branch_cond==2'b01 & ~Rs_zero) 
                        | (branch_cond==2'b10 & Rs_neg) | (branch_cond==2'b11 & ~Rs_neg);
    assign pc_branch = branch_taken ? pc_imm : pc_2;
    // assign newPC = branch ? pc_branch : pc_calc;
     assign Rs_zero = ~ (|Rs_data);
     assign Rs_neg = Rs_data[15];

    assign newPC = (halt) ? pc :
                   (reg_base) ? pc_reg :
                   (pc_base & jump) ? pc_imm :
                   (pc_base & ~jump) ? pc_branch : pc_2;

endmodule