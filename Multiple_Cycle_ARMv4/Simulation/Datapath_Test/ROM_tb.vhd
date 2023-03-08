library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity ROM_tb is
--  Port ( );
end ROM_tb;

architecture Behavioral of ROM_tb is

	constant N : positive := 6;
	constant M : positive := 32;
	
	-- Unit Under Test (UUT)
	Component ROM_Timed is
		port (
			CLK      :  in STD_LOGIC;
			RESET    :  in STD_LOGIC;
			
			ADDR     :  in STD_LOGIC_VECTOR (N-1 downto 0);
			DATA_OUT : out STD_LOGIC_VECTOR (M-1 downto 0));
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	 : STD_LOGIC := '0';
	signal RESET : STD_LOGIC := '1';
	
	signal ADDR	: STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');
	
	-- External Outputs to UUT
	signal DATA_OUT : STD_LOGIC_VECTOR(M-1 downto 0);
	
	-- Clock period definitions
	constant CLK_period : time := 8.2 ns;
	
	type ROM_Response_array is array (0 to 2**N-1) of STD_LOGIC_VECTOR (M-1 downto 0);
	
	constant ROM_Response : ROM_Response_array := (
	X"E2C00000", X"E2801005", X"E1E02001", X"E0513002",	-- 1h 16ada
	X"0A000000", X"51814003", X"E0015004", X"E5801004",
	X"EB00000F", X"E1A0A089", X"E1A000A0", X"E5906004",
	X"E2267009", X"E357000D", X"B2808050", X"E5808024",
	
	X"E08FF000", X"E3E02000", X"E590F024", X"EAFFFFEB",	-- 2h 16ada
	X"E245B00A", X"E28BC007", X"E1A0DFEC", X"E0C00000",
	X"EAFFFFE6", X"E2800001", X"E1B09141", X"62800064",
	X"22405032", X"E0C0F00E", X"00000000", X"00000000",
	
	X"00000000", X"00000000", X"00000000", X"00000000",	-- 3h 16ada
	X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000",
	
	X"00000000", X"00000000", X"00000000", X"00000000",	-- 4h 16ada
	X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000"
	);

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: ROM_Timed
		port map(
			CLK      => CLK,
			RESET    => RESET,
			ADDR     => ADDR,
			DATA_OUT => DATA_OUT
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
	
			-- UUT inputs are asserted and deasserted on CLK falling edge
			
			for I in 0 to 2**N-1 loop
				ADDR <= std_logic_vector(to_unsigned(I, ADDR'length));
				wait for clk_period;

				
				-- assert DATA_OUT = ROM_Response(I) report "OUTPUT PROBLEM" severity FAILURE;
				
			end loop;
			
			wait for clk_period;
			
			-- Message and stimulation end
			report "TEST COMPLETED";
			stop(2);
			
	end process;
	
	check_output: process (CLK)
		
	variable indicator : integer := -1;	--gia na metrame posoi kykloi perasan meta to reset
		
	begin
	
		if (falling_edge(CLK) and RESET = '0') then
			indicator := indicator + 1;
			
			-- epeidh exounme 2 DFF h ejodos tha jekinizei na allazei meta apo 1 kyklo + 0.5 kyklo
			-- epeidh h eisodos allazei sta falling edges tou CLK
			-- epeita oi allages sto output tha ginontai se kathe kyklo
			if (indicator >= 2) then
				assert DATA_OUT = ROM_Response(indicator-2) report "OUTPUT PROBLEM" severity FAILURE;
			end if;
		end if;
	
	end process;


end Behavioral;
