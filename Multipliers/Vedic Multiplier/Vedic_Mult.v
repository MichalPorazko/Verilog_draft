module Vedic_Mult#(parameter BIT_WIDTH = 16)(
    
    input wire [BIT_WIDTH - 1: 0] a,
    input  wire [BIT_WIDTH - 1: 0] b,
    output wire [(2*BIT_WIDTH - 1) : 0] out    
);    
    localparam HALF = BIT_WIDTH/2;

    wire [4*BIT_WIDTH - 1 : 0] internal_vedic_results;

    wire [BIT_WIDTH-1:0] adder1_sum;

    wire [2:0] carry_from_adders;

    genvar ia, ib;

    localparam index = (ia * 2) + ib;

    generate

        if ((BIT_WIDTH > 2) && (BIT_WIDTH%2 == 0 )) begin: recursive

                for (ia = 0; ia < 2; ia = ia + 1) begin

                    for (ib = 0; ib < 2; ib = ib + 1) begin

                        Vedic_Mult#(.BIT_WIDTH(HALF)) mult (
                            .a   (a[ia*HALF +: HALF]),
                            .b   (b[ib*HALF +: HALF]),
                            .out (internal_vedic_results[index * BIT_WIDTH +: BIT_WIDTH])  
                        );                        

                    end  

                end    

            out[HALF-1:0] = internal_vedic_results[HALF-1:0];


            CLA_grouped#(.(BIT_WIDTH)) adder_1 (
                .a(internal_vedic_results[2*BIT_WIDTH - 1: BIT_WIDTH]),
                .b(internal_vedic_results[3*BIT_WIDTH - 1: 2*BIT_WIDTH]),
                .cin(1'b0),
                .sum(adder1_sum)
                .carry(carry_from_adders[0])
            );

            CLA_grouped#(.(BIT_WIDTH)) adder_2 (
                .a(adder1_sum),
                .b({internal_vedic_results[BIT_WIDTH - 1: HALF], internal_vedic_results[3*BIT_WIDTH + HALF - 1: 3*BIT_WIDTH]}),
                .cin(1'b0),
                .sum(out [BIT_WIDTH + HALF-1 : HALF])
                .carry(carry_from_adders[1])
            );

            CLA_grouped#(.(HALF)) adder_3 (
                .a(internal_vedic_results[4*BIT_WIDTH - 1: 3*BIT_WIDTH+HALF]),
                .b({carry_from_adders[0] && carry_from_adders[1], 11'b0}),
                .cin(1'b0),
                .sum(out [BIT_WIDTH-1 : 3*HALF])
                .carry(out[BIT_WIDTH])
            );

        end elsif ((BIT_WIDTH > 2) && (BIT_WIDTH%2 != 0 )) begin

            wire [(2*(BIT_WIDTH-1))-1 : 0] vedic_out;

            Vedic_Mult#(BIT_WIDTH-1) mult1(
                .a( a[BIT_WIDTH-2:0]), 
                .b( b[BIT_WIDTH-2:0]),
                .out( vedic_out [BIT_WIDTH-2:0])    
            );

            out[BIT_WIDTH-2:0] = vedic_out [BIT_WIDTH-2:0];

            wire [(2*(BIT_WIDTH-1))-1 : 0] mux_outputs;


            assign mux_outputs[BIT_WIDTH-2:0] if b[BIT_WIDTH-1] == 1'b1 ? a[BIT_WIDTH-2 : 0] : 12'b0;
            assign mux_outputs[(2*(BIT_WIDTH-1))-1:BIT_WIDTH-1] if a[BIT_WIDTH-1] == 1'b1 ? b[BIT_WIDTH-2 : 0] : 12'b0;

            wire [BIT_WIDTH-2 : 0] adder1_sum;
            wire [2:0] carry_from_adders;

            CLA_grouped#(BIT_WIDTH-1) adder1 (
                .a( mux_outputs[BIT_WIDTH-2:0]),
                .b( mux_outputs[(2*(BIT_WIDTH-1))-1:BIT_WIDTH-1]),
                .cin (1'b0),
                .sum( adder1_sum),
                .carry( carry_from_adders[0])
            );

            CLA_grouped#(BIT_WIDTH-1) adder2 (
                .a( adder1_sum),
                .b( vedic_out[(2*(BIT_WIDTH-1))-1 : BIT_WIDTH-1]),
                .cin (1'b0),
                .sum( out[(2*(BIT_WIDTH-1))-1: BIT_WIDTH-1]),
                .carry( carry_from_adders[1])
            );

            

            full_adder_hardcoded(
                .a( (a[BIT_WIDTH]&b[BIT_WIDTH])),
                .b( carry_from_adders[1]),
                .c_in( carry_from_adders[0]),
                .cum( out[2*(BIT_WIDTH-1)]),
                c_out( out[2*(BIT_WIDTH) -1])
            );


        end else begin: two

            vedic_mult_2bit(
                .a( a),
                .b( b),
                .out( out)
            );

        end

    endgenerate


endmodule