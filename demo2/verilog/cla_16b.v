/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
module cla_16b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;

    // YOUR CODE HERE
    wire [N/4-1: 0] C;
    wire [N/4-1: 0] P,G,C_o;

    assign C[0] = C_in;
    cla_4b cla_add1[N/4-1: 0](.A(A), .B(B), .C_in(C), .S(S), .C_out(C_o), .G_out(G), .P_out(P));
    
    wire w1, w2, w3;
    nand2 and1(.in1(C[0]), .in2(P[0]), .out(w1));
    not1 n1(.in1(w1), .out(w2));
    nor2 or1(.in1(w2), .in2(G[0]), .out(w3));
    not1 n2(.in1(w3), .out(C[1]));

    wire w4, w5, w6, w7, w8;
    nand2 and2(.in1(P[1]), .in2(G[0]), .out(w4));
    nand2 and3(.in1(w2), .in2(P[1]), .out(w5));
    not1 n3(.in1(w4), .out(w6));
    not1 n4(.in1(w5), .out(w7));
    nor3 or2(.in1(w6), .in2(w7), .in3(G[1]), .out(w8));
    not1 n5(.in1(w8), .out(C[2]));
    
    wire w9, w10, w11, w12, w13, w14;
    nand2 and4(.in1(P[2]), .in2(G[1]), .out(w9));
    nand3 and5(.in1(G[0]), .in2(P[1]), .in3(P[2]), .out(w10));
    nand3 and6(.in1(w2), .in2(P[1]), .in3(P[2]), .out(w11));
    nand3 and7(.in1(w9), .in2(w10), .in3(w11), .out(w12));
    nor2 or3(.in1(w12), .in2(G[2]), .out(w13));
    not1 n6(.in1(w13), .out(C[3]));

    wire w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34;
    not1 n7(.in1(G[3]), .out(w24));
    nand3 and16(.in1(C[0]), .in2(P[0]), .in3(P[1]), .out(w25));
    not1 n10(.in1(w25), .out(w26));
    nand3 and17(.in1(w26), .in2(P[2]), .in3(P[3]), .out(w27));

    nand3 and18(.in1(G[0]), .in2(P[1]), .in3(P[2]), .out(w28));
    not1 n11(.in1(w28), .out(w29));
    nand2 and19(.in1(w29), .in2(P[3]), .out(w30));

    nand3 and20(.in1(G[1]), .in2(P[2]), .in3(P[3]), .out(w31));
    nand2 and21(.in1(G[2]), .in2(P[3]), .out(w32));

    nand3 and22(.in1(w27), .in2(w30), .in3(w31), .out(w33));
    not1 n12(.in1(w33), .out(w34));
    nand3 and23(.in1(w34), .in2(w32), .in3(w24), .out(C_out));


endmodule
