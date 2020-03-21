/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (mem_data, PC_2, ALU_data, signEx_data, wb_sel, wb_out);

   // TODO: Your code here
   input [15:0] mem_data, PC_2, ALU_data, signEx_data;
   input [1:0] wb_sel;
   output [15:0] wb_out;

   reg [15:0] mem_data_ed, PC_2_ed, ALU_data_ed, signEx_data_ed;
   mux4_1 wb_select[15:0](.InA(PC_2_ed), .InB(mem_data_ed), .InC(signEx_data_ed), 
                    .InD(ALU_data_ed), .S(wb_sel), .Out(wb_out)); 

   // pipeline stage
   dff mem_data_ff [15:0] (.d(mem_data), .clk(clk), .rst(rst), .q(mem_data_ed));
   dff PC_2_ff [15:0] (.d(PC_2), .clk(clk), .rst(rst), .q(PC_2_ed));
   dff ALU_data_ff [15:0] (.d(ALU_data), .clk(clk), .rst(rst), .q(ALU_data_ed));
   dff signEx_data_ff [15:0] (.d(signEx_data), .clk(clk), .rst(rst), .q(signEx_data_ed));

endmodule
