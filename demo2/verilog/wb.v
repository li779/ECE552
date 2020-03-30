/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (clk, rst, mem_data, PC_2, ALU_data, signEx_data, wb_sel, wb_out, Reg_write_mw, Reg_write_wd, Reg_d_sel_mw, Reg_d_sel_wd);

   // TODO: Your code here
   input [15:0] mem_data, PC_2, ALU_data, signEx_data;
   input [1:0] wb_sel;
   input Reg_write_mw;
   input clk, rst;
   input [2:0] Reg_d_sel_mw;
   output [15:0] wb_out;
   output Reg_write_wd;
   output [2:0] Reg_d_sel_wd;

   wire [15:0] mem_data_ed, PC_2_ed, ALU_data_ed, signEx_data_ed;
   wire [1:0] wb_sel_ed;
   mux4_1 wb_select[15:0](.InA(PC_2_ed), .InB(mem_data_ed), .InC(signEx_data_ed), 
                    .InD(ALU_data_ed), .S(wb_sel_ed), .Out(wb_out)); 

   // pipeline stage
   dff mem_data_ff [15:0] (.d(mem_data), .clk(clk), .rst(rst), .q(mem_data_ed));
   dff PC_2_ff [15:0] (.d(PC_2), .clk(clk), .rst(rst), .q(PC_2_ed));
   dff ALU_data_ff [15:0] (.d(ALU_data), .clk(clk), .rst(rst), .q(ALU_data_ed));
   dff signEx_data_ff [15:0] (.d(signEx_data), .clk(clk), .rst(rst), .q(signEx_data_ed));
   dff Reg_write_ff (.d(Reg_write_mw), .clk(clk), .rst(rst), .q(Reg_write_wd));
   dff wb_sel_ff [1:0] (.d(wb_sel), .clk(clk), .rst(rst), .q(wb_sel_ed));
   dff Reg_d_sel_ff [2:0] (.d(Reg_d_sel_mw), .clk(clk), .rst(rst), .q(Reg_d_sel_wd));

endmodule
