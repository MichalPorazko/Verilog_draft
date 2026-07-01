
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

constant MAC_WIDTH : integer := COEFF_WIDTH+INPUT_WIDTH;
  
type input_registers is array(0 to FILTER_TAPS-1) of signed(INPUT_WIDTH-1 downto 0);
signal areg_s  : input_registers := (others=>(others=>'0'));
  
type mult_registers is array(0 to FILTER_TAPS-1) of signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0);
signal mreg_s : mult_registers := (others=>(others=>'0'));
  
type dsp_registers is array(0 to FILTER_TAPS-1) of signed(MAC_WIDTH-1 downto 0);
signal preg_s : dsp_registers := (others=>(others=>'0'));
  
signal dout_s : std_logic_vector(MAC_WIDTH-1 downto 0);
signal sign_s : signed(MAC_WIDTH-INPUT_WIDTH-COEFF_WIDTH+1 downto 0) := (others=>'0');
  
-- Chebyshev 1kH LPF, causes overflow at low freq. 
type coefficients is array (0 to 59) of signed( 15 downto 0);

signal breg_s: coefficients :=( 

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
  
  
begin
  
  
data_o <= std_logic_vector(preg_s(0)(MAC_WIDTH-2 downto MAC_WIDTH-OUTPUT_WIDTH-1));         
        
  
process(clk)
begin
  
if rising_edge(clk) then
  
    if (reset = '1') then
        for i in 0 to FILTER_TAPS-1 loop
            areg_s(i) <=(others=> '0');
            mreg_s(i) <=(others=> '0');
            preg_s(i) <=(others=> '0');
        end loop;
  
    elsif (reset = '0') then      
        for i in 0 to FILTER_TAPS-1 loop
            areg_s(i) <= signed(data_i); 
        
            if (i < FILTER_TAPS-1) then
                mreg_s(i) <= areg_s(i)*breg_s(i);         
                preg_s(i) <= mreg_s(i) + preg_s(i+1);
                          
            elsif (i = FILTER_TAPS-1) then
                mreg_s(i) <= areg_s(i)*breg_s(i); 
                preg_s(i)<= mreg_s(i);
            end if;
        end loop; 
    end if;
      
end if;
end process;
  
end Behavioral;

endmodule Parallel_FIR_Filter;