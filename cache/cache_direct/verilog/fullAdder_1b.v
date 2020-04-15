/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out);
    input  A, B;
    input  C_in;
    output S;
    output C_out;

    // YOUR CODE HERE
    wire w1, w2, w3;
    xor2 x1(.in1(A), .in2(B), .out(w1));
    xor2 x2(.in1(w1), .in2(C_in), .out(S));
    nand2 and1(.in1(A), .in2(B), .out(w2));
    nand2 and2(.in1(w1), .in2(C_in), .out(w3));
    nand2 and3(.in1(w3), .in2(w2), .out(C_out));

endmodule
