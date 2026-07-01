
module Parallel_FIR_Filter#( parameter
    FILTER_TAPS  = 60,
    INPUT_WIDTH  = 24, 
    COEFF_WIDTH  = 16,
    OUTPUT_WIDTH = 24 
)( 
    clk    : in STD_LOGIC;
    reset  : in STD_LOGIC;
    enable : in STD_LOGIC;
    data_i : in STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);
    data_o : out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0)
);


    type input_registers is array(0 to FILTER_TAPS-1) of signed(INPUT_WIDTH-1 downto 0);
    signal delay_line_s  : input_registers := (others=>(others=>'0'));

    type coefficients is array (0 to 59) of signed( 15 downto 0);
    signal coeff_s: coefficients :=( 
    -- 500Hz Blackman LPF
    x"0000", x"0001", x"0005", x"000C", 
    x"0016", x"0025", x"0037", x"004E", 
    x"0069", x"008B", x"00B2", x"00E0", 
    x"0114", x"014E", x"018E", x"01D3", 
    x"021D", x"026A", x"02BA", x"030B", 
    x"035B", x"03AA", x"03F5", x"043B", 
    x"047B", x"04B2", x"04E0", x"0504", 
    x"051C", x"0528", x"0528", x"051C", 
    x"0504", x"04E0", x"04B2", x"047B", 
    x"043B", x"03F5", x"03AA", x"035B", 
    x"030B", x"02BA", x"026A", x"021D", 
    x"01D3", x"018E", x"014E", x"0114", 
    x"00E0", x"00B2", x"008B", x"0069", 
    x"004E", x"0037", x"0025", x"0016", 
    x"000C", x"0005", x"0001", x"0000");

    signal fsclk_q : std_logic := '0';

    type state_machine is (idle_st, active_st);
    signal state : state_machine := idle_st;

    signal counter : integer range 0 to FILTER_TAPS-1 := FILTER_TAPS-1;

    signal output       : signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0) := (others=>'0');
    signal accumulator  : signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0) := (others=>'0');
  
begin
  
data_o <= std_logic_vector(output(INPUT_WIDTH+COEFF_WIDTH-2 downto INPUT_WIDTH+COEFF_WIDTH-OUTPUT_WIDTH-1));
  
process(clk)
  
variable sum_v : signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0) := (others=>'0');
  
begin
  
    if rising_edge(clk) then
        fsclk_q <= fsclk;
          
        case state is
        when idle_st => 
            if fsclk = '1' and fsclk_q = '0' then
                state <= active_st;
            end if;
              
        when active_st =>
            -- Counter
            if counter > 0 then
                counter <= counter - 1;
            else
                counter <= FILTER_TAPS-1;
                state <= idle_st;
            end if;
              
            -- Delay line shifting
            if counter > 0 then
                delay_line_s(counter) <= delay_line_s(counter-1);
            else
                delay_line_s(counter) <= signed(data_i);
            end if;
              
            -- MAC operations
            if counter > 0 then
                sum_v := delay_line_s(counter)*coeff_s(counter);
                accumulator <= accumulator + sum_v;    
            else
                accumulator <= (others=>'0');
                sum_v := delay_line_s(counter)*coeff_s(counter);
                output <= accumulator + sum_v;  
            end if;
              
        end case;
    end if;
  
endmodule