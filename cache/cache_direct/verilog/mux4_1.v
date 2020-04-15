/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 1

    4-1 mux template
*/
module mux4_1(InA, InB, InC, InD, S, Out);
    input        InA, InB, InC, InD;
    input [1:0]  S;
    output       Out;

    // YOUR CODE HERE
    wire w1,w2;
    mux2_1 mux1(.InA(InA), .InB(InB), .S(S[0]), .Out(w1));
    mux2_1 mux2(.InA(InC), .InB(InD), .S(S[0]), .Out(w2));
    mux2_1 mux3(.InA(w1), .InB(w2), .S(S[1]), .Out(Out));

endmodule
