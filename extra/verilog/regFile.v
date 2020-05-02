/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   /* YOUR CODE HERE */
   wire [15:0] readfile [7:0];
   reg [7:0] enWrite;
   reg [15:0] read1Data;
   reg [15:0] read2Data;
   reg err1, err2;
   single_reg regs0 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[0]), .writeEn(enWrite[0]));
   single_reg regs1 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[1]), .writeEn(enWrite[1]));
   single_reg regs2 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[2]), .writeEn(enWrite[2]));
   single_reg regs3 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[3]), .writeEn(enWrite[3]));
   single_reg regs4 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[4]), .writeEn(enWrite[4]));
   single_reg regs5 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[5]), .writeEn(enWrite[5]));
   single_reg regs6 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[6]), .writeEn(enWrite[6]));
   single_reg regs7 (.clk(clk), .rst(rst), .writeData(writeData), .readData(readfile[7]), .writeEn(enWrite[7]));

   always@(*) begin
      enWrite = 8'b0;
      case(writeRegSel)
         3'h0: enWrite[0] = writeEn;
         3'h1: enWrite[1] = writeEn;
         3'h2: enWrite[2] = writeEn;
         3'h3: enWrite[3] = writeEn;
         3'h4: enWrite[4] = writeEn;
         3'h5: enWrite[5] = writeEn;
         3'h6: enWrite[6] = writeEn;
         3'h7: enWrite[7] = writeEn;
     endcase
   end

   always@(*) begin
	read1Data = 16'h0;
        err1 = 0;
      case(read1RegSel)
         3'h0: read1Data = readfile[0];
         3'h1: read1Data = readfile[1];
         3'h2: read1Data = readfile[2];
         3'h3: read1Data = readfile[3];
         3'h4: read1Data = readfile[4];
         3'h5: read1Data = readfile[5];
         3'h6: read1Data = readfile[6];
         3'h7: read1Data = readfile[7];
	 default: err1 = 1;
     endcase
   end

   always@(*) begin
	read2Data = 16'h0;
	err2 = 0;
      case(read2RegSel)
         3'h0: read2Data = readfile[0];
         3'h1: read2Data = readfile[1];
         3'h2: read2Data = readfile[2];
         3'h3: read2Data = readfile[3];
         3'h4: read2Data = readfile[4];
         3'h5: read2Data = readfile[5];
         3'h6: read2Data = readfile[6];
         3'h7: read2Data = readfile[7];
	 default: err2 = 1;
     endcase
   end

	assign err = 1'b0; // TODO err1|err2
endmodule
