module SIPO_register #(parameter output_width = 8 )(
    input clk,
    input  din,
    output [output_width-1 : 0] dout
);

    reg [output_width-1 : 0] temp;

    always_ff @( posedge clk ) begin 
        if (enable) begin
            temp <= {temp[output_width:1], din};
        end else begin
            temp <= 0;
        end
    end

    assign din = temp;    

endmodule