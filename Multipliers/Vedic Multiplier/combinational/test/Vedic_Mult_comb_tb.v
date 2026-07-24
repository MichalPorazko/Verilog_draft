`timescale 1ns/1ps

module Vedic_Mult_comb_tb;

    /* Width 6 exercises even recursion containing odd width-3 children. */
    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;
    localparam NUM_VALUES = (1 << BIT_WIDTH);

    reg  [BIT_WIDTH-1:0]   a;
    reg  [BIT_WIDTH-1:0]   b;
    wire [2*BIT_WIDTH-1:0] out;

    reg [2*BIT_WIDTH-1:0] expected;
    reg [2*BIT_WIDTH-1:0] a_extended;
    reg [2*BIT_WIDTH-1:0] b_extended;
    integer               a_value;
    integer               b_value;
    integer               errors;

    Vedic_Mult_comb #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .a   (a),
        .b   (b),
        .out (out)
    );

    initial begin
        errors = 0;

        for (a_value = 0; a_value < NUM_VALUES; a_value = a_value + 1) begin
            for (b_value = 0; b_value < NUM_VALUES; b_value = b_value + 1) begin
                a = a_value;
                b = b_value;
                #1;

                a_extended = {{BIT_WIDTH{1'b0}}, a};
                b_extended = {{BIT_WIDTH{1'b0}}, b};
                expected   = a_extended * b_extended;

                if (out !== expected) begin
                    $display("ERROR: a=%h b=%h dut=%h expected=%h",
                             a, b, out, expected);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("Vedic_Mult_comb_tb: PASS");
        else
            $display("Vedic_Mult_comb_tb: FAIL, errors=%0d", errors);

        $finish;
    end

endmodule
