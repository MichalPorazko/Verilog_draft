module calc_carries #(parameter GROUP_SIZE = 4)(
    input [GROUP_SIZE-1:0] p_in,
    input [GROUP_SIZE-1:0] g_in,
    input cin,
    output [GROUP_SIZE:0] carries,
    output P,
    output G

);            

    integer i, j;
    reg acc;
    reg prefix;
    reg [GROUP_SIZE:0] carries_temp,


    always @* begin
        carries_temp[0] = cin_in;

        for (i = 0; i < GROUP_SIZE; i = i + 1) begin
            acc    = g_in[i];
            prefix = p_in[i];

            for (j = i - 1; j >= 0; j = j - 1) begin
                acc    = acc | (prefix & g_in[j]);
                prefix = prefix & p_in[j];
            end

            carries_temp[i+1] = acc | (prefix & cin);
        end
    end
    carries = carries_temp;
    P = prefix;
    G = acc;

endmodule