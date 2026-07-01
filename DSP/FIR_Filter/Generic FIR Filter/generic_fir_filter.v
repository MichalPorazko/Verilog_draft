module	generic_fir_filter #(
		// {{{
		parameter		INUPUT_WIDTH = 16, TAP_WIDTH, OW=IW+TW+8,
		parameter [0:0]		FIXED_TAPS=0,
		parameter [(TW-1):0]	INITIAL_VALUE=0
		// }}}
	) (
		// {{{
		input	wire			i_clk, i_reset,
		// Coefficient setting/handling
		// {{{
		input	wire			i_tap_wr,
		input	wire	[(TW-1):0]	i_tap,
		output	wire signed [(TW-1):0]	o_tap,
		// }}}
		// Data pipeline
		// {{{
		input	wire			i_ce,
		input	wire signed [(IW-1):0]	i_sample,
		output	reg	[(IW-1):0]	o_sample,
		// }}}
		// Output "results"
		// {{{
		input	wire	[(OW-1):0]	i_partial_acc,
		output	reg	[(OW-1):0]	o_acc
		// }}}
		// }}}
	);