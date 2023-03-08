library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity REGgenrwe_tb is
--  Port ( );
end REGgenrwe_tb;

architecture Behavioral of REGgenrwe_tb is

	constant WIDTH : positive := 32;
	
-- Unit Under Test (UUT)
	Component REGgenrwe is
	Port (
		CLK   : in STD_LOGIC;
		RESET : in STD_LOGIC;
		WE    : in STD_LOGIC;
		D     : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		Q     :out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  : STD_LOGIC := '0';
	signal RESET  : STD_LOGIC := '1';
	signal WE	  : STD_LOGIC := '0';
	signal D      : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => 'X');
	
	-- Internal Output from UUT
	signal Q : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: REGgenrwe
			port map( 
				CLK   => CLK,
				RESET => RESET,
				WE	  => WE,
				D     => D,
				Q	  => Q								
			);
			
		-- H diadiakasia gia na dhmiourgisoume to roloi
		CLK_process : process
			begin
				CLK <= '0';
				wait for clk_period/2;
				CLK <= '1';
				wait for clk_period/2;
			end process;
			
	-- Stimulus process definition
		Stimulus_process: process
		
			begin
			--  Syncronous RESET is deasserted on CLK falling edge
			--  after GSR signal disable (it remains enabled for 100 ns)
				RESET <= '1';
				wait for 100 ns;
				wait until (CLK = '0' and CLK'event);
				RESET <= '0';
				WE    <= '1';
					
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			-- All paths from transition state diagram have to be activated
			-- After Reset deassert, D = X0
				
				D <= x"00000001";				
				wait for clk_period;
				
				WE <= '0';
				D  <= x"0000002B";
				wait for clk_period;
				
				D <= x"000000FF";
				wait for clk_period;
				
				WE <= '1';
				D  <= x"0000005B";
				wait for clk_period;
				
				RESET <= '1';
				wait for clk_period;
				
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;

end Behavioral;
