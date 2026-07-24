module calc_carries #(
    parameter GROUP_SIZE = 4
)(
    input  wire [GROUP_SIZE-1:0] p_in,
    input  wire [GROUP_SIZE-1:0] g_in,
    input  wire                  cin,
    output reg  [GROUP_SIZE:0]   carries,
    output reg                   P,
    output reg                   G
);

    integer i;
    integer j;
    reg acc;
    reg prefix;

    /*
     * Each carry is written as an expanded look-ahead expression.
     * Synthesis unrolls both loops because GROUP_SIZE is a parameter.
     */
    always @* begin
        carries    = {(GROUP_SIZE + 1){1'b0}};
        carries[0] = cin;
        P           = 1'b1;
        G           = 1'b0;
        acc         = 1'b0;
        prefix      = 1'b0;

        for (i = 0; i < GROUP_SIZE; i = i + 1) begin
            acc    = g_in[i];
            prefix = p_in[i];

            for (j = i - 1; j >= 0; j = j - 1) begin
                acc    = acc | (prefix & g_in[j]);
                prefix = prefix & p_in[j];
            end

            carries[i + 1] = acc | (prefix & cin);

            if (i == GROUP_SIZE - 1) begin
                G = acc;
                P = prefix;
            end
        end
    end

endmodule
