module hazard(Rs, Rt, Rd_mem, Rd_exe, Reg_wr_mem, Reg_wr_exe, jump, regRead, R_type, Reg_haz, exceptions, e2e_sel, m2e_sel, Memread, Memwrite, m2m_sel);
    // input
    input [2:0] Rs, Rt, Rd_exe, Rd_mem;
    input jump, regRead, R_type, Reg_wr_exe, Reg_wr_mem, exceptions, Memread, Memwrite;
    output [1:0] e2e_sel, m2e_sel;
    // output
    output Reg_haz, m2m_sel;
    // inner wires
    wire Rs_conf, Rs_read, Rt_conf, Rt_read, Reg_haz, m2m_haz;
    // Register write: Rs
    //assign Rs_conf = ((Rs == Rd_wb) & Reg_wr_wb) | ((Rs == Rd_mem) & Reg_wr_mem) | ((Rs == Rd_exe) & Reg_wr_exe);
    assign Rs_conf = ((Rs == Rd_mem) & Reg_wr_mem) | ((Rs == Rd_exe) & Reg_wr_exe);
    assign Rs_read = ((~jump) | regRead) & ~exceptions;
    // Register write: Rt
    //assign Rt_conf = ((Rt == Rd_wb) & Reg_wr_wb) | ((Rt == Rd_mem) & Reg_wr_mem) | ((Rt == Rd_exe) & Reg_wr_exe);
    assign Rt_conf = ((Rt == Rd_mem) & Reg_wr_mem) | ((Rt == Rd_exe) & Reg_wr_exe);
    assign Rt_read = R_type;

    //assign Reg_haz = ((Rs_conf & Rs_read)|(Rt_conf & Rt_read)) & (~((|e2e_sel)|(|m2e_sel)));
    // assign Reg_haz = ((Rs_conf & Rs_read)|(Rt_conf & Rt_read)) & Memread & (~Memwrite);
    // assign m2m_haz = Memread & Memwrite;
    // assign e2e_sel[0] = ((Rs == Rd_exe) & Reg_wr_exe) & Rs_read & ~m2m_haz;
    // assign e2e_sel[1] = ((Rt == Rd_exe) & Reg_wr_exe) & Rt_read & ~m2m_haz;

    // assign m2e_sel[0] = ((Rs == Rd_mem) & Reg_wr_mem) & Rs_read & ~m2m_haz;
    // assign m2e_sel[1] = ((Rt == Rd_mem) & Reg_wr_mem) & Rt_read & ~m2m_haz;

    // assign m2m_sel = (|e2e_sel) & m2m_haz;
    //assign Reg_haz = ((Rs_conf & Rs_read)|(Rt_conf & Rt_read)) & Memread;
    assign m2m_haz = Memread & Memwrite;
    assign e2e_sel[0] = ((Rs == Rd_exe) & Reg_wr_exe) & Rs_read;
    assign e2e_sel[1] = ((Rt == Rd_exe) & Reg_wr_exe) & Rt_read;

    assign m2e_sel[0] = ((Rs == Rd_mem) & Reg_wr_mem) & Rs_read;
    assign m2e_sel[1] = ((Rt == Rd_mem) & Reg_wr_mem) & Rt_read;

    //assign m2m_sel = 0;
    assign Reg_haz = ((Rs_conf & Rs_read)|(Rt_conf & Rt_read)) & Memread & (~m2e_sel);
    assign m2m_sel = Memread & Memwrite & (((Rt == Rd_exe) & Reg_wr_exe) & Rt_read);

endmodule