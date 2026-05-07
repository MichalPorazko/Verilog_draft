module calc_carry_block#(
    parameter BIT_WIDTH = 8
)(
        input  wire [31:0]          idx,
        input wire [BIT_WIDTH-1:0] g_in,
        input wire [BIT_WIDTH-1:0] p_in,
        output wire carry
);        
    reg acc, prefix;
    integer j;

    always@*    begin

        acc = g_in[idx];
        $display("calc_carry: acc initialized to g_in[%d]: %b", idx, acc);

        prefix = p_in[idx];
        $display("calc_carry: prefix initialized to p_in[%d]: %b", idx, prefix);

        for (j = idx - 1; j >= 0; j = j - 1) begin
            acc = acc | (prefix & g_in[j]);
            $display("calc_carry: acc updated to acc | (prefix & g_in[%d]): %b", j, acc);

            prefix = prefix & p_in[j];
            $display("calc_carry: prefix updated to prefix & p_in[%d]: %b", j, prefix);

        end

        carry = acc | (prefix & cin_in);
        $display("calc_carry: calc_carry result: %b", carry);

    end    

        
            

endmodule