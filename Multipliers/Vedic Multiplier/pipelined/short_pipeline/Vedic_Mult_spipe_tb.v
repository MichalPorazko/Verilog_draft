`timescale 1ns/1ps

module Vedic_Mult_spipe_tb;

    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;
    parameter NUM_CYCLES = 200;
    parameter LATENCY    = 1;

    reg                    clk;
    reg                    reset;
    reg                    valid_i;
    reg  [BIT_WIDTH-1:0]   a;
    reg  [BIT_WIDTH-1:0]   b;
    wire                   valid_o;
    wire [2*BIT_WIDTH-1:0] out;

    reg [2*BIT_WIDTH-1:0] expected_data [0:LATENCY-1];
    reg                   expected_valid[0:LATENCY-1];
    reg [BIT_WIDTH-1:0]   next_a;
    reg [BIT_WIDTH-1:0]   next_b;
    reg                   next_valid;
    integer               queue_index;
    integer               cycle;
    integer               errors;

    Vedic_Mult_spipe #(
        .BIT_WIDTH (BIT_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    ) dut (
        .clk     (clk),
        .reset   (reset),
        .valid_i (valid_i),
        .a       (a),
        .b       (b),
        .valid_o (valid_o),
        .out     (out)
    );

    function [2*BIT_WIDTH-1:0] reference_product;
        input [BIT_WIDTH-1:0] x;
        input [BIT_WIDTH-1:0] y;
        reg [2*BIT_WIDTH-1:0] x_extended;
        reg [2*BIT_WIDTH-1:0] y_extended;
        begin
            x_extended = {{BIT_WIDTH{1'b0}}, x};
            y_extended = {{BIT_WIDTH{1'b0}}, y};
            reference_product = x_extended * y_extended;
        end
    endfunction

    task check_and_push;
        input                   push_valid;
        input [BIT_WIDTH-1:0]   push_a;
        input [BIT_WIDTH-1:0]   push_b;
        begin
            if (valid_o !== expected_valid[LATENCY-1]) begin
                $display("ERROR valid at cycle %0d: dut=%b expected=%b",
                         cycle, valid_o, expected_valid[LATENCY-1]);
                errors = errors + 1;
            end

            if (expected_valid[LATENCY-1] &&
                (out !== expected_data[LATENCY-1])) begin
                $display("ERROR product at cycle %0d: dut=%h expected=%h",
                         cycle, out, expected_data[LATENCY-1]);
                errors = errors + 1;
            end

            for (queue_index = LATENCY - 1;
                 queue_index > 0;
                 queue_index = queue_index - 1) begin
                expected_valid[queue_index] = expected_valid[queue_index - 1];
                expected_data[queue_index]  = expected_data[queue_index - 1];
            end

            expected_valid[0] = push_valid;
            expected_data[0]  = reference_product(push_a, push_b);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk     = 1'b0;
        reset   = 1'b0;
        valid_i = 1'b0;
        a       = {BIT_WIDTH{1'b0}};
        b       = {BIT_WIDTH{1'b0}};
        errors  = 0;

        for (queue_index = 0; queue_index < LATENCY; queue_index = queue_index + 1) begin
            expected_valid[queue_index] = 1'b0;
            expected_data[queue_index]  = {(2*BIT_WIDTH){1'b0}};
        end

        repeat (2) @(negedge clk);
        reset = 1'b1;

        for (cycle = 0; cycle < NUM_CYCLES; cycle = cycle + 1) begin
            @(negedge clk);

            next_a     = $random;
            next_b     = $random;
            next_valid = ((cycle % 5) != 2);  // Regular bubbles exercise valid timing.

            check_and_push(next_valid, next_a, next_b);

            a       = next_a;
            b       = next_b;
            valid_i = next_valid;
        end

        for (cycle = NUM_CYCLES;
             cycle < NUM_CYCLES + LATENCY + 2;
             cycle = cycle + 1) begin
            @(negedge clk);
            check_and_push(1'b0, {BIT_WIDTH{1'b0}}, {BIT_WIDTH{1'b0}});
            a       = {BIT_WIDTH{1'b0}};
            b       = {BIT_WIDTH{1'b0}};
            valid_i = 1'b0;
        end

        if (errors == 0)
            $display("Vedic_Mult_spipe_tb: PASS");
        else
            $display("Vedic_Mult_spipe_tb: FAIL, errors=%0d", errors);

        $finish;
    end

endmodule
