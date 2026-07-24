module formal_Vedic_Mult_spipe;

    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;

    (* gclk *) reg clk;
    reg reset;

    (* anyseq *) reg                 valid_i;
    (* anyseq *) reg [BIT_WIDTH-1:0] a;
    (* anyseq *) reg [BIT_WIDTH-1:0] b;

    wire                   valid_o;
    wire [2*BIT_WIDTH-1:0] out;
    wire [2*BIT_WIDTH-1:0] a_extended;
    wire [2*BIT_WIDTH-1:0] b_extended;
    wire [2*BIT_WIDTH-1:0] product_ref;

    /* Independent one-stage reference pipeline. */
    reg                   ref_valid;
    reg [2*BIT_WIDTH-1:0] ref_out;
    reg                   check_enabled;

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

    assign a_extended = {{BIT_WIDTH{1'b0}}, a};
    assign b_extended = {{BIT_WIDTH{1'b0}}, b};
    assign product_ref = a_extended * b_extended;

    initial begin
        reset         = 1'b0;
        ref_valid     = 1'b0;
        ref_out       = {(2*BIT_WIDTH){1'b0}};
        check_enabled = 1'b0;
    end

    /* Hold reset low for the first formal edge, then run continuously. */
    always @(posedge clk) begin
        reset <= 1'b1;

        if (!reset) begin
            ref_valid     <= 1'b0;
            ref_out       <= {(2*BIT_WIDTH){1'b0}};
            check_enabled <= 1'b0;
        end else begin
            ref_valid     <= valid_i;
            check_enabled <= 1'b1;

            if (valid_i) begin
                ref_out <= product_ref;
            end
        end
    end

    /* Compare only after one complete non-reset clock transition. */
    always @* begin
        if (check_enabled) begin
            assert(valid_o == ref_valid);

            if (ref_valid) begin
                assert(out == ref_out);
            end
        end
    end

endmodule
