module formal_Vedic_Mult_lpipe;

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

    reg [3:0] f_history;

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
        reset     = 1'b0;
        f_history = 4'b0000;
    end

    always @(posedge clk) begin
        reset     <= 1'b1;
        f_history <= {f_history[2:0], 1'b1};

        if (f_history[0] && !$past(reset)) begin
            assert(valid_o == 1'b0);
        end

        if (f_history[3] && reset && $past(reset, 4)) begin
            assert(valid_o == $past(valid_i, 4));

            if ($past(valid_i, 4)) begin
                assert(out == $past(product_ref, 4));
            end
        end
    end

endmodule
