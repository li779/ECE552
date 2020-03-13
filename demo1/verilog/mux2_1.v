/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 1

    2-1 mux template
*/
module mux2_1(InA, InB, S, Out);
    input   InA, InB;
    input   S;
    output  Out;

    // YOUR CODE Here
    wire w1, w2, w3;
    nand2 and1(.in1(InB), .in2(S), .out(w1));
    not1 n1(.in1(S), .out(w2));
    nand2 and2(.in1(InA), .in2(w2), .out(w3));
    nand2 and3(.in1(w3), .in2(w1), .out(Out));

endmodule
