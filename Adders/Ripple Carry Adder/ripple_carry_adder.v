
module CRA #(parameter BIT_WIDTH)(input Cin, input [BIT_WIDTH-1:0] A, B, output [BIT_WIDTH-1:0]SUM, output CARRY);

    wire [BIT_WIDTH:0] c;
    assign c[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < BIT_WIDTH; i++) begin : g_fa
            full_adder fa (
                .a   (A[i]),
                .b   (B[i]),
                .cin (c[i]),
                .sum (SUM[i]),
                .cout(c[i+1])
            );
        end
    endgenerate

    assign CARRY = c[BIT_WIDTH];
endmodule