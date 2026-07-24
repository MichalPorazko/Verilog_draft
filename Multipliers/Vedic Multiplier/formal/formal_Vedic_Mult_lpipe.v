module formal_Vedic_Mult_lpipe;

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

    /* Independent four-stage reference pipeline. */
    reg                    ref_valid_1;
    reg                    ref_valid_2;
    reg                    ref_valid_3;
    reg                    ref_valid_4;
    reg [2*BIT_WIDTH-1:0]  ref_out_1;
    reg [2*BIT_WIDTH-1:0]  ref_out_2;
    reg [2*BIT_WIDTH-1:0]  ref_out_3;
    reg [2*BIT_WIDTH-1:0]  ref_out_4;
    reg                    reset_seen;

    Vedic_Mult_lpipe #(
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
        reset       = 1'b0;
        ref_valid_1 = 1'b0;
        ref_valid_2 = 1'b0;
        ref_valid_3 = 1'b0;
        ref_valid_4 = 1'b0;
        ref_out_1   = {(2*BIT_WIDTH){1'b0}};
        ref_out_2   = {(2*BIT_WIDTH){1'b0}};
        ref_out_3   = {(2*BIT_WIDTH){1'b0}};
        ref_out_4   = {(2*BIT_WIDTH){1'b0}};
        reset_seen  = 1'b0;
    end

    always @(posedge clk) begin
        reset <= 1'b1;

        if (!reset) begin
            ref_valid_1 <= 1'b0;
            ref_valid_2 <= 1'b0;
            ref_valid_3 <= 1'b0;
            ref_valid_4 <= 1'b0;
            ref_out_1   <= {(2*BIT_WIDTH){1'b0}};
            ref_out_2   <= {(2*BIT_WIDTH){1'b0}};
            ref_out_3   <= {(2*BIT_WIDTH){1'b0}};
            ref_out_4   <= {(2*BIT_WIDTH){1'b0}};
            reset_seen  <= 1'b1;
        end else begin
            ref_valid_1 <= valid_i;
            ref_valid_2 <= ref_valid_1;
            ref_valid_3 <= ref_valid_2;
            ref_valid_4 <= ref_valid_3;

            if (valid_i) begin
                ref_out_1 <= product_ref;
            end

            if (ref_valid_1) begin
                ref_out_2 <= ref_out_1;
            end

            if (ref_valid_2) begin
                ref_out_3 <= ref_out_2;
            end

            if (ref_valid_3) begin
                ref_out_4 <= ref_out_3;
            end
        end
    end

    always @* begin
        if (reset_seen) begin
            assert(valid_o == ref_valid_4);

            if (ref_valid_4) begin
                assert(out == ref_out_4);
            end
        end
    end

endmodule
