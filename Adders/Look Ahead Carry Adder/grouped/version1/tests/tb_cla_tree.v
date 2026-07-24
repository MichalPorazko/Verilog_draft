`timescale 1ns/1ps

module tb_cla_tree;

    /* WIDTH=6 deliberately exercises a 4-bit group followed by a 2-bit group. */
    parameter WIDTH      = 6;
    parameter GROUP_SIZE = 4;
    localparam NUM_VALUES = (1 << WIDTH);

    reg  [WIDTH-1:0] p;
    reg  [WIDTH-1:0] g;
    reg              cin;
    wire [WIDTH:0]   carry;
    wire             P;
    wire             G;

    reg [WIDTH:0] expected_carry;
    reg             expected_G;
    integer         p_value;
    integer         g_value;
    integer         cin_value;
    integer         bit_index;
    integer         errors;

    cla_tree #(
        .BIT_WIDTH (WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .g     (g),
        .p     (p),
        .cin   (cin),
        .carry (carry),
        .G     (G),
        .P     (P)
    );

    initial begin
        errors = 0;

        for (p_value = 0; p_value < NUM_VALUES; p_value = p_value + 1) begin
            for (g_value = 0; g_value < NUM_VALUES; g_value = g_value + 1) begin
                for (cin_value = 0; cin_value < 2; cin_value = cin_value + 1) begin
                    p   = p_value;
                    g   = g_value;
                    cin = cin_value;

                    expected_carry    = {(WIDTH + 1){1'b0}};
                    expected_carry[0] = cin_value;
                    expected_G        = 1'b0;

                    for (bit_index = 0;
                         bit_index < WIDTH;
                         bit_index = bit_index + 1) begin
                        expected_carry[bit_index + 1] =
                            g[bit_index] |
                            (p[bit_index] & expected_carry[bit_index]);

                        expected_G =
                            g[bit_index] |
                            (p[bit_index] & expected_G);
                    end

                    #1;

                    if (carry !== expected_carry) begin
                        $display("ERROR carry: p=%b g=%b cin=%b dut=%b expected=%b",
                                 p, g, cin, carry, expected_carry);
                        errors = errors + 1;
                    end

                    if (P !== (&p)) begin
                        $display("ERROR P: p=%b dut=%b expected=%b", p, P, &p);
                        errors = errors + 1;
                    end

                    if (G !== expected_G) begin
                        $display("ERROR G: p=%b g=%b dut=%b expected=%b",
                                 p, g, G, expected_G);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0)
            $display("tb_cla_tree: PASS");
        else
            $display("tb_cla_tree: FAIL, errors=%0d", errors);

        $finish;
    end

endmodule
