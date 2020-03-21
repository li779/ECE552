module single_reg(
                // Outputs
                readData,
                // Inputs
                clk, rst, writeData, writeEn
                );
   parameter W = 16;
   input        clk, rst;
   input [W-1:0] writeData;
   input        writeEn;

   output [W-1:0] readData;

   
   wire [W-1:0] in;
   dff flops[W-1:0] (.d(in), .clk(clk), .rst(rst), .q(readData));
   assign in = writeEn ? writeData : readData;

endmodule 
