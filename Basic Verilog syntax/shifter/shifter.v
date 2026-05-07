// shift_scratch.v

module shift_scratch;

    reg  [3:0] x;
    reg  [7:0] y;

    initial begin
        x = 4'b1011;

        $display("x              = %b", x);
        $display("x << 1         = %b", x << 1);
        $display("x << 2         = %b", x << 2);

        y = x << 2;

        $display("y = x << 2     = %b", y);

        $finish;
    end

endmodule