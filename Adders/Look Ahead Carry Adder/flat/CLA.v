module CLA #(
    parameter BIT_WIDTH = 64
) (
    input  wire [BIT_WIDTH-1:0] A,
    input  wire [BIT_WIDTH-1:0] B,
    input  wire                 Cin,
    output wire [BIT_WIDTH-1:0] SUM,
    output wire                 CARRY
);

    wire [BIT_WIDTH-1:0] g, p;
    wire [BIT_WIDTH:0]   c;

    assign g = A & B;

    assign p = A ^ B;

    assign c[0] = Cin;
    genvar i;

    always @(*) begin       
        generate
            for (i = 0; i < BIT_WIDTH; i = i + 1) begin : gen_cla
                assign c[i+1] = calc_carry_block(i, g, p, Cin);

                assign SUM[i] = p[i] ^ c[i];
            end
        endgenerate
        
    end



    assign CARRY = c[BIT_WIDTH];

endmodule