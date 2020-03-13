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
   mux4_1 wb_select[15:0](.InA(PC_2), .InB(mem_data), .InC(signEx_data), 
                    .InD(ALU_data), .S(wb_sel), .Out(wb_out));                                   
endmodule
