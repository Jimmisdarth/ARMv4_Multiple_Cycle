library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity SZEXTEND_tb is
--  Port ( );
end SZEXTEND_tb;

architecture Behavioral of SZEXTEND_tb is

	constant WIDTH_IN  : positive := 24;
	constant WIDTH_OUT : positive := 32;
	
-- Unit Under Test (UUT)
	Component SZEXTEND is
		port (
			SorZ   :  in STD_LOGIC;
			SZ_in  :  in STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0);
			SZ_out : out STD_LOGIC_VECTOR (WIDTH_OUT-1 downto 0));
	end Component;
	
	-- Internal Inputs to UUT
	signal SorZ  : STD_LOGIC := '0';
	signal SZ_in : STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0) := (others => 'X');
	
	-- Internal Output from UUT
	signal SZ_out : STD_LOGIC_VECTOR (WIDTH_OUT-1 downto 0);
	
	-- Clock period definitions
	signal CLK : STD_LOGIC := '0';
	constant CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: SZEXTEND
			port map(
				SorZ   => SorZ,  
				SZ_in  => SZ_in, 
				SZ_out => SZ_out
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
				wait for 10 ns;
				wait until (CLK = '0' and CLK'event);			
					
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			-- All paths from transition state diagram have to be activated
			-- After Reset deassert, 
				
				SorZ  <= '0';
				wait for clk_period;
				
				-- Elegxoume oti ta prwta 12 jhdia ginontai extend swsta
				for I in 0 to 2**12-1 loop
					SZ_in <= std_logic_vector(to_unsigned(I, SZ_in'length));
					wait for clk_period;
					
					assert (SZ_Out=std_logic_vector(to_unsigned(I, SZ_Out'length))) report "PROBLEM_1" severity FAILURE;
				end loop;
				
				wait for clk_period;
				
				-- Elegxoume ta ypoloipa 12 apo 24 jhfia, edw sto SZ_out ta 12 pio
				-- Shmantika jhfia tha prepei na einai ola 0
				for I in 2**12 to 2**24-1 loop
					SZ_in <= std_logic_vector(to_unsigned(I, SZ_in'length));
					wait for clk_period;
					
					assert (SZ_Out(31 downto 12) = x"00000") report "PROBLEM_AT_ZEROS" severity FAILURE;
					assert (SZ_Out(11 downto 0) = std_logic_vector(to_unsigned(I, 12))) report "PROBLEM_AT_ZEROS" severity FAILURE;
				end loop;
				
				SorZ <= '1';
				wait for clk_period;
				
				-- Elegxos gia olous tous thetikous arithmous me 24 bit anaparastash
				for I in 0 to 2**23-1 loop
					SZ_in <= std_logic_vector(to_unsigned(I, SZ_in'length));
					wait for clk_period;
					
					assert (SZ_Out=std_logic_vector(to_unsigned(4*I, SZ_Out'length))) report "PROBLEM_3" severity FAILURE;
				end loop;
				
				wait for clk_period;
				
				-- Elegxos gia olous tous arnhitkous arithmous me 24 bit anaparastash
				for I in -1 downto -2**23 loop
					SZ_in <= std_logic_vector(to_signed(I, SZ_in'length));
					wait for clk_period;
					
					assert (to_integer(signed(SZ_Out))=4*I) report "PROBLEM_3" severity FAILURE;
				end loop;
				
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;

end Behavioral;
