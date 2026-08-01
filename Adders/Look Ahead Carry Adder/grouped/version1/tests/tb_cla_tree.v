`timescale 1ns/1ps

module tb_cla_tree;

    parameter WIDTH      = 16;
    parameter GROUP_SIZE = 4;
    parameter NUM_RANDOM = 5000;

    reg  [WIDTH-1:0] p;
    reg  [WIDTH-1:0] g;
    reg              cin;

    wire [WIDTH:0]   c;
    wire             P;
    wire             G;

    integer i;
    integer errors;

    reg [WIDTH:0] expected_c;
    reg [WIDTH:0] expected_c_zero;
    reg           expected_P;
    reg           expected_G;

    cla_tree #(
        .WIDTH(WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .p   (p),
        .g   (g),
        .cin (cin),
        .c   (c),
        .P   (P),
        .G   (G)
    );

    function [WIDTH:0] ref_carries;
        input [WIDTH-1:0] p_in;
        input [WIDTH-1:0] g_in;
        input             cin_in;

        integer bi, bj;
        reg acc;
        reg prefix;

        begin
            ref_carries[0] = cin_in;

            for (bi = 0; bi < WIDTH; bi = bi + 1) begin
                acc    = g_in[bi];
                prefix = p_in[bi];

                for (bj = bi - 1; bj >= 0; bj = bj - 1) begin
                    acc    = acc | (prefix & g_in[bj]);
                    prefix = prefix & p_in[bj];
                end

                ref_carries[bi+1] = acc | (prefix & cin_in);
            end
        end
    endfunction

    task check_case;
        input [WIDTH-1:0] p_case;
        input [WIDTH-1:0] g_case;
        input             cin_case;
        begin
            p   = p_case;
            g   = g_case;
            cin = cin_case;
            #1;

            expected_c      = ref_carries(p_case, g_case, cin_case);
            expected_c_zero = ref_carries(p_case, g_case, 1'b0);
            expected_P      = &p_case;
            expected_G      = expected_c_zero[WIDTH];

            if (c !== expected_c) begin
                $display("ERROR(c):   p=%b g=%b cin=%b -> c=%b expected=%b",
                         p_case, g_case, cin_case, c, expected_c);
                errors = errors + 1;
            end

            if (P !== expected_P) begin
                $display("ERROR(P):   p=%b -> P=%b expected=%b",
                         p_case, P, expected_P);
                errors = errors + 1;
            end

            if (G !== expected_G) begin
                $display("ERROR(G):   p=%b g=%b -> G=%b expected=%b",
                         p_case, g_case, G, expected_G);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        // Directed tests
        check_case({WIDTH{1'b0}}, {WIDTH{1'b0}}, 1'b0);
        check_case({WIDTH{1'b0}}, {WIDTH{1'b0}}, 1'b1);
        check_case({WIDTH{1'b1}}, {WIDTH{1'b0}}, 1'b0);
        check_case({WIDTH{1'b1}}, {WIDTH{1'b0}}, 1'b1);
        check_case({WIDTH{1'b0}}, {WIDTH{1'b1}}, 1'b0);
        check_case({WIDTH{1'b0}}, {WIDTH{1'b1}}, 1'b1);

        check_case(16'h0001, 16'h0000, 1'b1);
        check_case(16'h00FF, 16'h0001, 1'b0);
        check_case(16'hFFFF, 16'h0001, 1'b0);
        check_case(16'hAAAA, 16'h5555, 1'b0);
        check_case(16'h5555, 16'hAAAA, 1'b1);

        // Random tests
        for (i = 0; i < NUM_RANDOM; i = i + 1) begin
            check_case($random, $random, $random);
        end

        if (errors == 0)
            $display("tb_cla_tree: PASS");
        else
            $display("tb_cla_tree: FAIL, errors=%0d", errors);

        $finish;
    end

endmodule