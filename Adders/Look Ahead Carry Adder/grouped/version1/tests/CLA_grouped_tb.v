module CLA_grouped_tb;



    reg [BIT_WIDTH-1:0] a;
    reg [BIT_WIDTH-1:0] b;
    wire                 cin;
    wire [BIT_WIDTH-1:0] sum;
    wire                 carry;


    CLA_grouped #(.BIT_WIDTH(16), .GROUP_SIZE(4)) cla_16;

    CLA_grouped #(.BIT_WIDTH(4)), .GROUP_SIZE(4)) cla_4;

    CLA_grouped #(.BIT_WIDTH(64), .GROUP_SIZE(4)) cla_64;

    initial begin


        


    end    



endmodule