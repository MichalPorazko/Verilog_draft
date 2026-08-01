module calc_carry_block_tb;

    reg [31:0]          idx;
    reg [BIT_WIDTH-1:0] g_in;
    reg [BIT_WIDTH-1:0] p_in;
    wire carry;

    calc_carry_block #(.BIT_WIDTH(4)) dut (
        .idx(idx),
        .g_in(g_in),
        .p_in(p_in),
        .carry(carry)
    );

    initial begin

        $dumpfile("cla.fst");
        /*
            If level = 0, then all variables within the modules from the list will be dumped.
                If any module from the list contains module instances, 
            then all variables from these modules will also be dumped.
            If level = 1, then only listed variables and variables of listed modules will be dumped.
        */
        $dumpvars(0, CLA_tb);
    end 

    initial begin
        $display(" time   idx       g_in        p_in        carry");
        $monitor("%4t   %b %b   %b  %b ",
                 $time,idx, g_in, p_in, carry);

        assign wire A = 4'b1111;
        assign wire B = 4'b0001;

        idx = 3; g_in = A&B; p_in = A^B; Cin = 1'b0; #10;

        $finish;
    end  

endmodule