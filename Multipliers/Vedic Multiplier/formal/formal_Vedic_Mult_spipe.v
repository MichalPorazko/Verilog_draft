module formal_Vedic_Mult_spipe;

    parameter BIT_WIDTH  = 6;
    parameter GROUP_SIZE = 4;

    (* gclk *) reg clk;
    reg reset;

    (* anyseq *) reg                   valid_i;
    (* anyseq *) reg [BIT_WIDTH-1:0]   a;
    (* anyseq *) reg [BIT_WIDTH-1:0]   b;

    wire                   valid_o;
    wire [2*BIT_WIDTH-1:0] out;
    wire [2*BIT_WIDTH-1:0] a_extended;
    wire [2*BIT_WIDTH-1:0] b_extended;
    wire [2*BIT_WIDTH-1:0] product_ref;

    reg f_past_valid;

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
        reset        = 1'b0;
        f_past_valid = 1'b0;
    end

    /* Hold reset low for the first formal edge, then run continuously. */
    always @(posedge clk) begin
        reset        <= 1'b1;
        f_past_valid <= 1'b1;

        if (f_past_valid && !$past(reset)) begin
            assert(valid_o == 1'b0);
        end

        if (f_past_valid && reset && $past(reset)) begin
            assert(valid_o == $past(valid_i));

            if ($past(valid_i)) begin
                assert(out == $past(product_ref));
            end
        end
    end

endmodule
