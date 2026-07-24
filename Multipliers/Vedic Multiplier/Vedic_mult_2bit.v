module vedic_mult_2bit(
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [3:0] out
);

    wire cross_0;
    wire cross_1;
    wire high_pp;
    wire carry_1;

    assign out[0] = a[0] & b[0];

    assign cross_0 = a[1] & b[0];
    assign cross_1 = a[0] & b[1];
    assign high_pp = a[1] & b[1];

    assign out[1] = cross_0 ^ cross_1;
    assign carry_1 = cross_0 & cross_1;

    assign out[2] = carry_1 ^ high_pp;
    assign out[3] = carry_1 & high_pp;

endmodule
