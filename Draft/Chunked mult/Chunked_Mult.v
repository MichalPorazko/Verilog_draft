module Chunked_Mult #(
    parameter A_WIDTH     = 16,
    parameter B_WIDTH     = 16,
    parameter CHUNK_WIDTH = 4
)(
    input  wire [A_WIDTH-1:0] a,
    input  wire [B_WIDTH-1:0] b,
    output wire [A_WIDTH+B_WIDTH-1:0] out
);

    localparam OUT_WIDTH = A_WIDTH + B_WIDTH;

    localparam A_CHUNKS = (A_WIDTH + CHUNK_WIDTH - 1) / CHUNK_WIDTH;
    localparam B_CHUNKS = (B_WIDTH + CHUNK_WIDTH - 1) / CHUNK_WIDTH;

    localparam NUM_PP = A_CHUNKS * B_CHUNKS;

    wire [OUT_WIDTH-1:0] pp [0:NUM_PP-1];
    wire [OUT_WIDTH-1:0] sum_stage [0:NUM_PP];

    assign sum_stage[0] = {OUT_WIDTH{1'b0}};

    genvar i, j;

    generate
        for (i = 0; i < A_CHUNKS; i = i + 1) begin : gen_a_chunks
            for (j = 0; j < B_CHUNKS; j = j + 1) begin : gen_b_chunks

                localparam integer A_START = i * CHUNK_WIDTH;
                localparam integer B_START = j * CHUNK_WIDTH;

                localparam integer A_THIS_WIDTH =
                    (A_START + CHUNK_WIDTH <= A_WIDTH) ?
                    CHUNK_WIDTH :
                    (A_WIDTH - A_START);

                localparam integer B_THIS_WIDTH =
                    (B_START + CHUNK_WIDTH <= B_WIDTH) ?
                    CHUNK_WIDTH :
                    (B_WIDTH - B_START);

                localparam integer PP_INDEX = i * B_CHUNKS + j;

                wire [A_THIS_WIDTH-1:0] a_part;
                wire [B_THIS_WIDTH-1:0] b_part;

                wire [A_THIS_WIDTH+B_THIS_WIDTH-1:0] raw_product;

                assign a_part = a[A_START +: A_THIS_WIDTH];
                assign b_part = b[B_START +: B_THIS_WIDTH];

                assign raw_product = a_part * b_part;

                assign pp[PP_INDEX] =
                    ({{(OUT_WIDTH-(A_THIS_WIDTH+B_THIS_WIDTH)){1'b0}}, raw_product})
                    << (A_START + B_START);

            end
        end
    endgenerate

    genvar k;

    generate
        for (k = 0; k < NUM_PP; k = k + 1) begin : gen_sum
            assign sum_stage[k+1] = sum_stage[k] + pp[k];
        end
    endgenerate

    generate
    for (i = 0; i < A_CHUNKS; i = i + 1) begin : gen_a_chunks
        for (j = 0; j < B_CHUNKS; j = j + 1) begin : gen_b_chunks

            // ... same localparams/wires/assigns ...

            always @* begin
                $display("t=%0t i=%0d j=%0d a_part=%b b_part=%b raw_product=%b pp[%0d]=%b",
                         $time, i, j, a_part, b_part, raw_product, PP_INDEX, pp[PP_INDEX]);
            end

        end
    end
endgenerate

    assign out = sum_stage[NUM_PP];

endmodule