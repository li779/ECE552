/*
    CS/ECE 552 Spring '20
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the Op() value that is passed in (2 bit number).  It uses these
    shifts to shift the value any number of bits between 0 and 15 bits.
 */
module shifter (In, Cnt, Op, Out);

   // declare constant for size of inputs, outputs (N) and # bits to shift (C)
   parameter   N = 16;
   parameter   C = 4;
   parameter   O = 2;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   input [O-1:0]   Op;
   output [N-1:0]  Out;

   /* YOUR CODE HERE */
    wire [N-1:0] In2b, In4b, In8b;
    shift_layer #(16, 1, 2) shift1b (.In(In), .Isuse(Cnt[0]), .Op(Op), .Out(In2b));
    shift_layer #(16, 2, 2) shift2b (.In(In2b), .Isuse(Cnt[1]), .Op(Op), .Out(In4b));
    shift_layer #(16, 4, 2) shift4b (.In(In4b), .Isuse(Cnt[2]), .Op(Op), .Out(In8b));
    shift_layer #(16, 8, 2) shift8b (.In(In8b), .Isuse(Cnt[3]), .Op(Op), .Out(Out));
   
endmodule
