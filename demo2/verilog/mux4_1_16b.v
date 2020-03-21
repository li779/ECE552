/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 1

    a 16-bit (quad) 4-1 Mux template
*/
module mux4_1_16b(InA, InB, InC, InD, S, Out);

    // parameter N for length of inputs and outputs (to use with larger inputs/outputs)
    parameter N = 16;

    input [N-1:0]   InA, InB, InC, InD;
    input [1:0]     S;
    output [N-1:0]  Out;

    // YOUR CODE HERE
    mux4_1 sel[N-1:0](.InA(InA), .InB(InB), .InC(InC), .InD(InD), .S(S), .Out(Out));

endmodule