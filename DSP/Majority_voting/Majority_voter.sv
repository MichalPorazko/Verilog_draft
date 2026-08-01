module Majority_voter #(parameter registers_num = 8) (

    input logic enable,
    input din,
    input clk,
    output logic dout 
);

    reg [registers_num -1 : 0] temp;
    logic temp_out;


    SIPO_register sipo(
        .clk(clk),
        .din(din),
        .dout(temp)
    );

    integer i,k;

    always_comb begin 
        for (i = 0; i< registers_num; i = i + 1) begin
            for (j = i + 1; j< registers_num; j = j + 1) begin

                temp_out = temp_out | temp[i] & temp[j]

            end 
        end 
    end

    assign dout = temp_out;    


endmodule: Majority_voter