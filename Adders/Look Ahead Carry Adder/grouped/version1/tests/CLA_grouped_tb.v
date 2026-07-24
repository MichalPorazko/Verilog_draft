`timescale 1ns/1ps

module CLA_grouped_tb;

    /* BIT_WIDTH=6 proves that GROUP_SIZE does not need to divide the width. */
    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;
    localparam NUM_VALUES = (1 << BIT_WIDTH);

    reg  [BIT_WIDTH-1:0] a;
    reg  [BIT_WIDTH-1:0] b;
    reg                  cin;
    wire [BIT_WIDTH-1:0] sum;
    wire                 carry;

    reg [BIT_WIDTH:0] expected;
    integer           a_value;
    integer           b_value;
    integer           cin_value;
    integer           errors;

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

    initial begin
        errors = 0;

        for (a_value = 0; a_value < NUM_VALUES; a_value = a_value + 1) begin
            for (b_value = 0; b_value < NUM_VALUES; b_value = b_value + 1) begin
                for (cin_value = 0; cin_value < 2; cin_value = cin_value + 1) begin
                    a   = a_value;
                    b   = b_value;
                    cin = cin_value;
                    #1;

                    expected = {1'b0, a} + {1'b0, b} + cin;

                    if ({carry, sum} !== expected) begin
                        $display("ERROR: a=%h b=%h cin=%b dut=%h expected=%h",
                                 a, b, cin, {carry, sum}, expected);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0)
            $display("CLA_grouped_tb: PASS");
        else
            $display("CLA_grouped_tb: FAIL, errors=%0d", errors);

        $finish;
    end

endmodule
