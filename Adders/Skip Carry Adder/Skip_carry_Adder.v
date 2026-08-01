
module csea #(parameter BIT_WIDTH, GROUP_SIZE)(
 input [BIT_WIDTH:0] A , B ,
 input Cin ,
 output [BIT_WIDTH:0] Sum ,
 output Cout
) ;

    genvar i;

    wire [BIT_WIDTH:0] P;

    wire [BIT_WIDTH:0] c_x;
    assign c_x[0] = Cin;


    generate for (i = 0; i < BIT_WIDTH; i = i + 1) begin
                xor(P[i], A[i], B[i]);
             end
    endgenerate

    reg [63:0] large_bus;

    wire P_xor_all;
    assign P_xor_all = ^P;

    if (P_xor_all == 1) begin
        generate for (i = 0; i < BIT_WIDTH; i = i + 1) begin

                xor(Sum[i], P[i], c_x[i]);
                
                end 
        endgenerate

    end else begin
        generate for (i = 0; i < BIT_WIDTH; i = i + 1) begin

                reduced_full_adder(A[i], B[i], c_x[i], P[i], Sum[i], c_x[i+1]);

                if (i == BIT_WIDTH)
                    assign cout = c_x[BIT_WIDTH];

             end
        endgenerate
        

    end        
        

endmodule


module reduced_full_adder(A, B, Ci, P, S, Co);
  input A, B, Ci;
  output S, Co;
  wire G, PC;
  
  xor (S, P, Ci);
  and (PC, P, Ci);
  and (G, A, B);
  or G5(Co, G, PC);
endmodule

