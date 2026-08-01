module vedic_mult_2bit(a,b,out);
    input [1:0]a,b;
    output [3:0]out;

    wire w1,w2,w3;
    wire c1;

    assign out[0] = a[0] & b[0];

    assign w1 = a[1] & b[0];
    assign w2 = a[0] & b[1];
    assign w3 = a[1] & b[1];

    half_adder h1(w1,w2,out[1],c1);
    half_adder h2(c1,w3,out[2],out[3]);


endmodule