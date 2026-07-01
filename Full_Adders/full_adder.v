module full_adder_v1 ( 
    input a, 
    input b, 
    input c_in, 
    output sum, 
    output c_out 
);

    assign sum = a ^ b ^ c_in;
    assign c_out = (a & b) | (c_in & (a ^ b));

endmodule





