module CIA_RCA #(
    parameter BIT_WIDTH
) (
    input Cin, input [BIT_WIDTH-1:0] A, B, output [BIT_WIDTH-1:0]SUM, output CARRY
);

    wire half_bit = BIT_WIDTH  / 2 - 1;
    wire sum_1 = 

    CLA cla1(Cin, A[half_bit:0], B[half_bit:0])
    
endmodule