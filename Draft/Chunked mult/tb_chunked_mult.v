`timescale 1ns/1ps

module tb_chunked_mult;

    localparam A_WIDTH     = 16;
    localparam B_WIDTH     = 16;
    localparam CHUNK_WIDTH = 4;
    localparam OUT_WIDTH   = A_WIDTH + B_WIDTH;

    reg  [A_WIDTH-1:0] a;
    reg  [B_WIDTH-1:0] b;
    wire [OUT_WIDTH-1:0] out;

    Chunked_Mult #(
        .A_WIDTH(A_WIDTH),
        .B_WIDTH(B_WIDTH),
        .CHUNK_WIDTH(CHUNK_WIDTH)
    ) dut (
        .a(a),
        .b(b),
        .out(out)
    );

    initial begin
        $dumpfile("chunked_mult.fst");
        $dumpvars(0, tb_chunked_mult);

        a = 16'h0000; b = 16'h0000; #10;
        a = 16'h0003; b = 16'h0005; #10;
        a = 16'h1234; b = 16'h00FF; #10;
        a = 16'hABCD; b = 16'h1357; #10;
        a = 16'hFFFF; b = 16'hFFFF; #10;

        $finish;
    end

    initial begin
        $monitor("t=%0t a=%h b=%h out=%h",
                 $time, a, b, out);
    end

endmodule