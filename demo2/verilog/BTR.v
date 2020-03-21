module BTR(data, result);
    input [15:0] data;
    output wire [15:0] result;

    assign result[0] = data[15];
    assign result[1] = data[14];
    assign result[2] = data[13];
    assign result[3] = data[12];
    assign result[4] = data[11];
    assign result[5] = data[10];
    assign result[6] = data[9];
    assign result[7] = data[8];
    assign result[8] = data[7];
    assign result[9] = data[6];
    assign result[10] = data[5];
    assign result[11] = data[4];
    assign result[12] = data[3];
    assign result[13] = data[2];
    assign result[14] = data[1];
    assign result[15] = data[0];
endmodule