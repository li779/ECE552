module arith_Op(Op, real_in1, real_in2, C_in, S_out, C_out);


   localparam ADD = 2'b00;
   localparam AND = 2'b11;
   localparam SUB = 2'b01;
   localparam XOR = 2'b10;

   input wire [1:0] Op; 
   input C_in;
   input [15:0] real_in1, real_in2;
   output reg [15:0] S_out;
   output wire C_out;

   wire [15:0] sum;
    cla_16b adder(.A(real_in1), .B(real_in2), .C_in(C_in), .S(sum), .C_out(C_out));

    // assign S_out = (Op == AND) ? (real_in1 & real_in2) :
    //                (Op == XOR) ? (real_in1 ^ real_in2) : sum;
                   

always@(*) begin
    case (Op)
    ADD    :      S_out = sum;
    AND    :      S_out = real_in1 & real_in2; 
    XOR     :      S_out = real_in1 ^ real_in2;    
    default:      S_out = sum;
    endcase
end


endmodule

