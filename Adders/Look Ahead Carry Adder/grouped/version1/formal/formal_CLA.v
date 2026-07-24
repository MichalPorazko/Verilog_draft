module formal_CLA;

    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;

    (* anyconst *) reg [BIT_WIDTH-1:0] a;
    (* anyconst *) reg [BIT_WIDTH-1:0] b;
    (* anyconst *) reg                 cin;

    wire [BIT_WIDTH-1:0] sum;
    wire                 carry;
    wire [BIT_WIDTH:0]   sum_ref;

    CLA #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .a     (a),
        .b     (b),
        .cin   (cin),
        .sum   (sum),
        .carry (carry)
    );

    assign sum_ref = {1'b0, a} + {1'b0, b} + cin;

    always @* begin
        assert({carry, sum} == sum_ref);
    end

endmodule
