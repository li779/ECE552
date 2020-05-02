
module shift_layer (In, Isuse, Op, Out);
    parameter   N = 16;
    parameter   C = 4;
    parameter   O = 2;

    localparam rll = 3'b000;
    localparam sll = 3'b001;
    localparam ror = 3'b010;
    localparam srl = 3'b011;

    input [N-1:0]   In;
    input [O-1:0]   Op;
    input Isuse;
    output [N-1:0]  Out;

    wire[N-1:0] stage;
    assign stage = (Op == rll) ? {In[N-C-1:0], In[N-1: N-C]} :
                 (Op == sll) ? {In[N-C-1:0], {C{1'b0}}} :
                 (Op == srl) ? {{C{1'b0}}, In[N-1: C]} : {In[N-C-1:0], In[N-1: N-C]};
    assign Out = Isuse ? stage : In;

endmodule 