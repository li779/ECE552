/*
   CS/ECE 552 Spring '20
  
   Filename        : immediate.v
   Description     : This is the module for immediate extension.
*/
module immediate (instr, immed);
    input [15:0] instr;
    output reg [15:0] immed;
    // 5_bit sign_extended
    //assign immed = {instr[4:0]}
always@(instr) begin
    casex (instr[15:11])
        5'b010xx: immed = (instr[12] == 0) ? {{11{instr[4]}} , instr[4:0]} 
                                           : {11'h000 , instr[4:0]};
        5'b10010: immed = {8'h00, instr[7:0]};
        5'b100xx: immed = {{11{instr[4]}} , instr[4:0]};
        5'b011xx: immed = {{8{instr[7]}}, instr[7:0]};
        5'b11000: immed = {{8{instr[7]}}, instr[7:0]};
        5'b001xx: immed = (instr[11] == 0)? {{5{instr[10]}} , instr[10:0]}
                                           : {{8{instr[7]}} , instr[7:0]};
        5'b11010: immed = {12'b0, instr[3:0]};
        5'b101xx: immed = {12'b0, instr[3:0]};
        default : immed = 16'h0000;
    endcase
end
endmodule