`timescale 1ns/1ps

module CLA_tb #(
    parameter BIT_WIDTH = 4
);

    reg [BIT_WIDTH-1:0] A;
    reg [BIT_WIDTH-1:0] B;
    reg                 Cin;
    wire [BIT_WIDTH-1:0] SUM;
    wire                 CARRY;

    CLA # (.BIT_WIDTH(4))cla (
               .A(A),
               .B(B),
               .Cin(Cin),
               .SUM(SUM),
               .CARRY(CARRY)
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
        $display(" time   A         B         Cin | g         p         c         SUM       CARRY");
        $monitor("%4t   %b %b   %b  | %b %b %b %b   %b",
                 $time, A, B, Cin, cla.g, cla.p, cla.c, SUM, CARRY);

        A   = 4'b0000; B = 4'b0000; Cin = 1'b0; #10;
        A   = 4'b1111; B = 4'b0001; Cin = 1'b0; #10;
        A   = 4'b1011; B = 4'b0001; Cin = 1'b0; #10;
        A   = 4'b0010; B = 4'b0111; Cin = 1'b1; #10;
        A   = 4'b0011; B = 4'b1000; Cin = 1'b1; #10;

        $finish;
    end        

endmodule