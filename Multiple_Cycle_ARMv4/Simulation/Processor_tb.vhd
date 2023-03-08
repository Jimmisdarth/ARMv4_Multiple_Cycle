library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity Processor_tb is
--  Port ( );
end Processor_tb;

architecture Behavioral of Processor_tb is

	constant WIDTH : positive := 32;
	
	-- Unit Under Test (UUT)
	Component Processor is
		port (
			CLK 		:  in STD_LOGIC;
			RESET       :  in STD_LOGIC;
			
			PC 			: out STD_LOGIC_VECTOR(WIDTH-17 downto 0);
			Instruction : out STD_LOGIC_VECTOR(WIDTH-1  downto 0);
			ALUResult   : out STD_LOGIC_VECTOR(WIDTH-1  downto 0);
			WriteData   : out STD_LOGIC_VECTOR(WIDTH-1  downto 0);
			Result      : out STD_LOGIC_VECTOR(WIDTH-1  downto 0));
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 		: STD_LOGIC := '0';
	signal RESET       : STD_LOGIC := '1';
	
	-- External Outputs to UUT
	signal PC 			: STD_LOGIC_VECTOR(WIDTH-17 downto 0);
	signal Instruction : STD_LOGIC_VECTOR(WIDTH-1  downto 0);
	signal ALUResult   : STD_LOGIC_VECTOR(WIDTH-1  downto 0);
	signal WriteData   : STD_LOGIC_VECTOR(WIDTH-1  downto 0);
	signal Result      : STD_LOGIC_VECTOR(WIDTH-1  downto 0);
	
	-- Clock period definitions
	constant CLK_period : time := 8.2 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: Processor
			port map(
				CLK 		=> CLK, 		
				RESET       => RESET,      
                               
				PC 			=> PC, 			
				Instruction => Instruction,
				ALUResult   => ALUResult,  
				WriteData   => WriteData,  
				Result      => Result     
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
				
				wait for 101*clk_period;
				
				-- gia to timing toy implementation
				wait for clk_period;
				
				-- Tha prepei na egrafei h timh 4 ston kataxwrhth logo ths entolhs ROR
				assert PC 		   = x"0058" 	 report "ROR Program Counter PROBLEM" severity FAILURE;
				assert Instruction = x"E1A0DFEC" report "ROR Instruction PROBLEM"     severity FAILURE;
				assert ALUResult   = x"00000004" report "ROR ALUResult PROBLEM"       severity FAILURE;
				assert WriteData   = x"00000002" report "ROR WriteData PROBLEM"       severity FAILURE;
				assert Result      = x"00000004" report "ROR Result PROBLEM" 	      severity FAILURE;
				
				wait for 4*clk_period;
				
				-- Entolh NOP MOV R0, R0 
				assert PC 		   = x"005C" 	 report "MOV Program Counter PROBLEM" severity FAILURE;
				assert Instruction = x"E0C00000" report "MOV Instruction PROBLEM"     severity FAILURE;
				assert ALUResult   = x"00000000" report "MOV ALUResult PROBLEM"       severity FAILURE;
				assert WriteData   = x"00000000" report "MOV WriteData PROBLEM"       severity FAILURE;
				assert Result      = x"00000000" report "MOV Result PROBLEM" 	      severity FAILURE;
				
				wait for 4*clk_period;
				
				-- gia to timing toy implementation
				wait for clk_period;
				
				-- Tha prepei na exei ginei Bracnh sthn arxh tou programatos 
				assert PC 		   = x"0000" 	 report "MOV Program Counter PROBLEM" severity FAILURE;
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;


end Behavioral;
