/*
    CS/ECE 552 Spring '20
    Homework #2, Problem 2

    A 16-bit ALU module.  It is designed to choose
    the correct operation to perform on 2 16-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the 16-bit result
    of the operation, as well as output a Zero bit and an Overflow
    (OFL) bit.
*/
module alu (InA, InB, Cin, Op, invA, invB, sign, Out, Zero, Ofl, C_out);

   // declare constant for size of inputs, outputs (N),
   // and operations (O)
   parameter    N = 16;
   parameter    O = 3;
   
   localparam rll = 3'b000;
   localparam sll = 3'b001;
   localparam ror = 3'b010;
   localparam srl = 3'b011;
   localparam ADD = 3'b100;
   localparam AND = 3'b111;
   localparam SUB = 3'b101;
   localparam XOR = 3'b110;

   input [N-1:0] InA;
   input [N-1:0] InB;
   input         Cin;
   input [O-1:0] Op;
   input         invA;
   input         invB;
   input         sign;
   output wire [N-1:0] Out;
   output wire  Ofl;
   output     Zero;
   output     C_out;
   /* YOUR CODE HERE */
    wire [N-1:0] real_in1, real_in2;
    wire [N-1:0] S_out, A_out;
    wire [3:0] shft_count, add_count;

    assign real_in1 = invA? ~InA: InA;
    assign real_in2 = invB? ~InB: InB; 
/*
    case (invA)
    1'b1      : assign real_in1 = ~InA;
    default: assign real_in1 = InA;
    endcase

    case (invB)
    1      : assign real_in2 = ~InB;
    default: assign real_in2 = InB;
    endcase
*/

    shifter shift1(.In(real_in1), .Cnt(shft_count), .Op(Op[1:0]), .Out(A_out));
    cla_4b adder(.A(real_in2[3:0]), .B(4'b0), .C_in(1'b1), .S(add_count), .C_out(), .G_out(), .P_out());
    arith_Op op1(.Op(Op[1:0]), .real_in1(real_in1), .real_in2(real_in2), .C_in(Cin), .S_out(S_out), .C_out(C_out));
   
    assign Out = Op[2] ? S_out : A_out;
    assign shft_count = (Op == 2'b10) ? add_count : real_in2[3:0];

/*always@(*) begin
    case (Op[2])
    1      :     Out = S_out;   // the arthmatic operation part
    default:     Out = A_out; // shifter part
    endcase
end
*/

    // overflow cases for signed and unsigned additions (if operation is not )

    assign Ofl = ((Op == 3'b100) & sign) ? (S_out[N-1]^C_out^real_in1[N-1]^real_in2[N-1]) :
                 ((Op == 3'b100) & ~sign) ? C_out : 0;

/*always@(*) begin
  case (Op)
    3'b100  : begin
		assign Ofl = sign ? (S_out[N-1]^C_out^real_in1[N-1]^real_in2[N-1]) : C_out;
              end
    default : assign Ofl = 0;
  endcase
end
*/
    assign Zero = ~(|S_out);
endmodule
