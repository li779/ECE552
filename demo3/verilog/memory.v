/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (pass, imme, imme_next, data_in, data_out, addr_pre, clk, rst, pc_2, pc_2_ed, 
               wb_sel_ed, result_mw, Reg_write_wd, Reg_d_sel_wd, data_m2e, data_m2m, data_stall);

    // TODO: Your code here
    output [15:0] data_out, data_m2e, data_m2m;
    output [15:0] pc_2_ed, imme_next, result_mw;
    output [1:0] wb_sel_ed;
    output Reg_write_wd, data_stall;
    output [2:0] Reg_d_sel_wd;
    input [15:0] data_in, imme, pc_2;
    input [15:0] addr_pre;
    input clk;
    input rst; 
    input [8:0] pass;
    /*
   0 = St_sel;
   1 = Ld_sel;
   2 = halt;
   3-4 = wb_sel;
   */

    wire[8:0] pass;
    wire halt, memRead, memWrite;
    wire [15:0] mem_data;
    wire Reg_write_mw;
    wire [2:0] Reg_d_sel;
    wire [1:0] wb_sel;
    wire mem_stall;
    wire Done;

    assign mem_stall = data_stall;

    assign memRead = pass[1];
    assign memWrite = pass[0] & ~halt;
    assign halt = pass[2];
    assign wb_sel = pass[4:3];
    assign Reg_write_mw = (~mem_stall) ? pass[5] : 1'b0;
    assign Reg_d_sel = pass[8:6];
    assign data_m2m = mem_data;

    //memory2c memory_file (.data_out(mem_data), .data_in(data_in), .addr(addr_pre), .enable((memRead|memWrite)&(~halt)), 
     //                     .wr(memWrite), .createdump(halt), .clk(clk), .rst(rst));
    mem_system #(1) memory_file(.DataOut(mem_data), .Done(Done), .Stall(data_stall), .CacheHit(), 
                           .err(), .Addr(addr_pre), .DataIn(data_in), .Rd(memRead), .Wr(memWrite), 
                           .createdump(), .clk(clk), .rst(rst));

    mux4_1 wb_select[15:0](.InA(pc_2), .InB(mem_data), .InC(imme), 
                    .InD(addr_pre), .S(wb_sel), .Out(data_m2e));
    // pipeline stage
    // dff data_ff [15:0] (.d(data_in), .clk(clk), .rst(rst), .q(data));
    // dff pass_ff [8:0] (.d(pass_pre), .clk(clk), .rst(rst), .q(pass));
    // dff addr_ff [15:0] (.d(addr_pre), .clk(clk), .rst(rst), .q(result_mw));
    // dff pc_2_ff [15:0] (.d(pc_2_pre), .clk(clk), .rst(rst), .q(pc_2));
    // dff imme_ff [15:0] (.d(imme_pre), .clk(clk), .rst(rst), .q(imme));

   single_reg mem_data_ff (.writeData(mem_data), .clk(clk), .rst(rst), .readData(data_out), .writeEn(~mem_stall));
   single_reg PC_2_ff (.writeData(pc_2), .clk(clk), .rst(rst), .readData(pc_2_ed), .writeEn(~mem_stall));
   single_reg ALU_data_ff (.writeData(addr_pre), .clk(clk), .rst(rst), .readData(result_mw), .writeEn(~mem_stall));
   single_reg signEx_data_ff (.writeData(imme), .clk(clk), .rst(rst), .readData(imme_next), .writeEn(~mem_stall));
   single_reg #(1) Reg_write_ff (.writeData(Reg_write_mw), .clk(clk), .rst(rst), .readData(Reg_write_wd), .writeEn(~mem_stall));
   single_reg #(2) wb_sel_ff (.writeData(wb_sel), .clk(clk), .rst(rst), .readData(wb_sel_ed), .writeEn(~mem_stall));
   single_reg #(3) Reg_d_sel_ff (.writeData(Reg_d_sel), .clk(clk), .rst(rst), .readData(Reg_d_sel_wd), .writeEn(~mem_stall));

endmodule
