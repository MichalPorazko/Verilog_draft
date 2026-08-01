module calc_group_c#(parameter GROUP_SIZE = 4, BIT_WIDTH = 64)(
    input [31:0] bit_idx,
    input [BIT_WIDTH - 1: 0] p, g,
    input cin,
    output carry
);

    wire acc, prefix;
    integer j;
    integer lo = (bit_idx / GROUP_SIZE) * GROUP_SIZE;

    if (lo == bit_idx) begin
        carry = cin;
    end    

    always@*    begin

        acc = g[idx-1];
        $display("calc_carry: acc initialized to g_in[%d]: %b", idx, acc);

        prefix = p[idx-1];
        $display("calc_carry: prefix initialized to p_in[%d]: %b", idx, prefix);

        for (j = idx - 2; j >= lo; j = j - 1) begin
            acc = acc | (prefix & g[j]);
            $display("calc_carry: acc updated to acc | (prefix & g_in[%d]): %b", j, acc);

            prefix = prefix & p[j];
            $display("calc_carry: prefix updated to prefix & p_in[%d]: %b", j, prefix);

        end

        carry = acc | (prefix & cin);
        $display("calc_carry: calc_carry result: %b", carry);

    end    
    


endmodule