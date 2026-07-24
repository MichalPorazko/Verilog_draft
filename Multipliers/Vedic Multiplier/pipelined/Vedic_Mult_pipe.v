module Vedic_Mult_pipe#(parameter BIT_WIDTH = 16)(
    
    input [BIT_WIDTH - 1: 0] a,
    input  [BIT_WIDTH - 1: 0] b,
    input clk,
    input reset,
    output [(2*BIT_WIDTH - 1) : 0] out    
);    
    localparam HALF = BIT_WIDTH/2;

    //stage 1
    wire [BIT_WIDTH - 1 : 0] p_ll, p_lh, p_hl, p_hh;
    reg [BIT_WIDTH - 1 : 0] p_ll_r, p_lh_r, p_hl_r, p_hh_r;
    
    //stage 2
    wire [BIT_WIDTH-1:0] adder1_sum; 
    wire carry1;
    reg [BIT_WIDTH-1:0] adder1_sum_r, p_ll_delay, p_hh_delay;
    reg carry1_r;
    
    //stage3
    wire [BIT_WIDTH-1:0] adder2_sum;
    wire carry2;
    reg [HALF - 1:0] p_ll_low_r, p_hh_high_r;
    reg [BIT_WIDTH-1:0] adder2_sum_r;
    reg carry1_r_delay, carry2_r;

    //stage 4
    reg [BIT_WIDTH-1:0] adder2_sum_delay;
    reg [HALF - 1:0] p_ll_low_delay, p_hh_high_delay;
    reg or_gate_r;

    //stage 5
    wire [HALF - 1:0] half_adder_sum;
    reg [HALF - 1:0] half_adder_sum_r, p_ll_low_delay;
    wire [BIT_WIDTH-1:0] adder2_sum_delay;


    if ((BIT_WIDTH > 2) && (BIT_WIDTH%2 == 0 )) begin: 



            Vedic_Mult_comb#(.WIDTH(HALF))(
                .a(a[HALF-1:0]),
                .b(b[HALF-1:0]),
                .out(p_ll)
            );

            Vedic_Mult_comb#(.WIDTH(HALF))(
                .a(a[HALF-1:0]),
                .b(b[BIT_WIDTH-1:HALF]),
                .out(p_lh)
            );
            
            Vedic_Mult_comb#(.WIDTH(HALF))(
                .a(a[BIT_WIDTH-1:HALF]),
                .b(b[HALF-1:0]),
                .out(p_hl)
            );
            
            Vedic_Mult_comb#(.WIDTH(HALF))(
                .a(a[BIT_WIDTH-1:HALF]),
                .b(b[BIT_WIDTH-1:HALF]),
                .out(p_hh)
            );


        always @(posedge clk) begin

            if (!reset) begin

            p_ll_r <= 0;
            p_lh_r <= 0;
            p_hl_r <= 0;
            p_hh_r <= 0;

            end else begin
            
            p_ll_r <= p_ll;
            p_lh_r <= p_lh;
            p_hl_r <= p_hl;
            p_hh_r <= p_hh;
                
            end         

        end    

        CLA#(.BIT_WIDTH(BIT_WIDTH), .GROUP_SIZE(4))(
            .a(p_lh_r),
            .b(p_hl_r),
            .cin(1'b0),
            .sum(adder1_sum),
            .carry(carry1)
        );

        always @(posedge clk) begin

            if (!reset) begin

            p_ll_delay <= 0;
            adder1_sum_r <= 0;
            carry1_r <= 0;
            p_hh_delay <= 0;

            end else begin
            
            p_ll_delay <= p_ll_r;
            adder1_sum_r <= adder1_sum;
            carry1_r <= carry1;
            p_hh_delay <= p_hh_r;
                
            end         

        end 

        CLA#(.BIT_WIDTH(BIT_WIDTH), .GROUP_SIZE(4))(
            .a(adder1_sum_r),
            .b({p_hh_delay[HALF-1:0], p_ll_delay[BIT_WIDTH-1:HALF]}),
            .cin(1'b0),
            .sum(adder2_sum),
            .carry(carry2)
        );

        always @(posedge clk) begin

            if (!reset) begin

            p_ll_low_r <= 0;
            adder2_sum_r <= 0;
            carry2_r <= 0;
            p_hh_high_r <= 0;
            carry1_r_delay <= 0;

            end else begin
            
            p_ll_low_r <= p_ll_delay[HALF-1:0];
            adder2_sum_r <= adder2_sum;
            carry2_r <= carry2;
            p_hh_high_r <= p_hh_delay[BIT_WIDTH-1:HALF];
            carry1_r_delay <= carry1_r;

            end         

        end 

        assign wire or_gate = carry1_r_delay || carry2_r;

        CLA#(.BIT_WIDTH(HALF), .GROUP_SIZE())(
            .a(p_hh_high_delay),
            .b(or_gate_r),
            .cin(1'b0),
            .sum(half_adder_sum),

        );

        always @(posedge clk) begin

            if (!reset) begin

            out <= 0;

            end else begin
            
            out <= {half_adder_sum, adder2_sum_delay, p_ll_low_delay};

            end         

        end 

    end elsif ((BIT_WIDTH > 2) && (BIT_WIDTH%2 != 0 )) begin

            wire [(2*(BIT_WIDTH-1))-1 : 0] vedic_out;

            Vedic_Mult_pipe#(BIT_WIDTH-1) mult1(
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
    

    assert_property(out = a *b);
    assume_property(!$isunknown(a) & !$isunknown(b));

endmodule