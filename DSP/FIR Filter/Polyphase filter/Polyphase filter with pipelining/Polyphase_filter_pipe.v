

module	Polyphase_filter_pipe #(
		
		parameter		NTAPS=128, INUPUT_WIDTH = 12, TAP_WIDTH = 12, OW=2*IW+$clog2(NTAPS),
		parameter [0:0]		FIXED_TAPS=0,
		parameter CONVERSION_FACTOR = 4
		
	) (
		
		input	wire			i_clk, i_reset,
		
		input	wire			i_tap_wr,	// Ignored if FIXED_TAPS
		input	wire	[(TW-1):0]	i_tap,		// Ignored if FIXED_TAPS
		
		input	wire			i_ce,
		input	wire	[(IW-1):0]	i_sample,
		output	wire	[(OW-1):0]	o_result
		
	);


	wire	[(TAP_WIDTH-1):0] tap		[NTAPS:0];
	wire	[(TW-1):0] tapout	[NTAPS:0];

	reg [(INUPUT_WIDTH + TAP_WIDTH) : 0] tempMult;
	localparam TEMP_ADD_LENGTH = INUPUT_WIDTH > TAP_WIDTH ? INUPUT_WIDTH : TAP_WIDTH; 
	reg [TEMP_ADD_LENGTH : 0] tempAdd;


	int i, j;

	always @(i_clk) begin
		for (i = 0; i < CONVERSION_FACTOR; i= i + 1) begin
			
			localparam jlimit = ((CONVERSION_FACTOR * i) > NTAPS) ? (CONVERSION_FACTOR * i) : NTAPS;	
			



			for (j = 0; j <= jlimit ; j = j + 1) begin
				   Vedic_Mult #(.BIT_WIDTH(INUPUT_WIDTH)) ved_mult (
						.a(i_sample[CONVERSION_FACTOR * i - j]),
						.b(i_tap[j]),
						.out(tempMult)
				   );

					CLA_grouped#(.BIT_WIDTH(INUPUT_WIDTH)) adder (
						.A(tempAdd),
						.B(tempMult),
						.Cin(1'b0),
						.SUM(tempAdd[TEMP_ADD_LENGTH - 1 : 0]),
						.CARRY(TEMP_ADD_LENGTH)	
					);	

			end	
			

		end
	end



endmodule    