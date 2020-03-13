
module carry(A,B,P,G);
    input A,B;
    output P,G;

    wire w1,w2;
    nand2 and1(.in1(A), .in2(B), .out(w1));
    nor2 or1(.in1(A), .in2(B), .out(w2));
    not1 n1(.in1(w1), .out(G));
    not1 n2(.in1(w2), .out(P));

endmodule