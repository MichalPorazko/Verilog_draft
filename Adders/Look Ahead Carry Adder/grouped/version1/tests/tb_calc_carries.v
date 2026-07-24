`timescale 1ns/1ps

module tb_calc_carries;

    parameter GROUP_SIZE = 4;
    localparam NUM_VALUES = (1 << GROUP_SIZE);

    reg  [GROUP_SIZE-1:0] p_in;
    reg  [GROUP_SIZE-1:0] g_in;
    reg                   cin;
    wire [GROUP_SIZE:0]   carries;
    wire                  P;
    wire                  G;

    reg [GROUP_SIZE:0] expected_carries;
    reg                  expected_G;
    integer              p_value;
    integer              g_value;
    integer              cin_value;
    integer              bit_index;
    integer              errors;

    calc_carries #(
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .p_in    (p_in),
        .g_in    (g_in),
        .cin     (cin),
        .carries (carries),
        .P       (P),
        .G       (G)
    );

    initial begin
        errors = 0;

        for (p_value = 0; p_value < NUM_VALUES; p_value = p_value + 1) begin
            for (g_value = 0; g_value < NUM_VALUES; g_value = g_value + 1) begin
                for (cin_value = 0; cin_value < 2; cin_value = cin_value + 1) begin
                    p_in = p_value;
                    g_in = g_value;
                    cin  = cin_value;

                    /* Independent ripple recurrence used only by the testbench. */
                    expected_carries    = {(GROUP_SIZE + 1){1'b0}};
                    expected_carries[0] = cin_value;
                    expected_G          = 1'b0;

                    for (bit_index = 0;
                         bit_index < GROUP_SIZE;
                         bit_index = bit_index + 1) begin
                        expected_carries[bit_index + 1] =
                            g_in[bit_index] |
                            (p_in[bit_index] & expected_carries[bit_index]);

                        expected_G =
                            g_in[bit_index] |
                            (p_in[bit_index] & expected_G);
                    end

                    #1;

                    if (carries !== expected_carries) begin
                        $display("ERROR carries: p=%b g=%b cin=%b dut=%b expected=%b",
                                 p_in, g_in, cin, carries, expected_carries);
                        errors = errors + 1;
                    end

                    if (P !== (&p_in)) begin
                        $display("ERROR P: p=%b dut=%b expected=%b", p_in, P, &p_in);
                        errors = errors + 1;
                    end

                    if (G !== expected_G) begin
                        $display("ERROR G: p=%b g=%b dut=%b expected=%b",
                                 p_in, g_in, G, expected_G);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0)
            $display("tb_calc_carries: PASS");
        else
            $display("tb_calc_carries: FAIL, errors=%0d", errors);

        $finish;
    end

endmodule
