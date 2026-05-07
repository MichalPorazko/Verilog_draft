module calc_group_gp#(parameter GROUP_SIZE = 4)(

    input [GROUP_SIZE - 1: 0] p, g,
    input cin,
    output carry
);

    integer i;
    wire acc, prefix;

    for (i = GROUP_SIZE - 1; i <= 0; i = i -1) begin
        acc = acc | (prefix * g[i]);
        prefix = prefix * p[i];
    end
    carry = acc | (prefix * cin);
    


endmodule