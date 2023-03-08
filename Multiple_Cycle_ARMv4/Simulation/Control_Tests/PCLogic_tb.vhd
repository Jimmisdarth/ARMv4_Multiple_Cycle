library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity PCLogic_tb is
--  Port ( );
end PCLogic_tb;

architecture Behavioral of PCLogic_tb is

	-- Unit Under Test (UUT)
	Component PCLogic is
		port ( 
			RegWrite_in :  in STD_LOGIC;
			
			Rd			:  in STD_LOGIC_VECTOR(3 downto 0);
			op 			:  in STD_LOGIC_VECTOR(1 downto 0);
			PCSrc_in    : out STD_LOGIC);
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	
	signal RegWrite_in : STD_LOGIC := 'X';
	signal Rd          : STD_LOGIC_VECTOR(3 downto 0) := (others => 'X');
	signal op          : STD_LOGIC_VECTOR(1 downto 0) := (others => 'X');

	-- External Outputs to UUT
	signal PCSrc_in   : STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;	

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: PCLogic
		port map( 
			RegWrite_in => RegWrite_in,
                           
			Rd			=> Rd,
			op 			=> op,
			PCSrc_in    => PCSrc_in
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
			
			variable CONCATENATE_IN : STD_LOGIC_VECTOR(6 downto 0);
		
			begin
				
				RegWrite_in <= '0';
				op          <= "00";
			    Rd          <= "0000";
				wait for 10 ns;
				wait until (CLK = '0' and CLK'event);
				
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			
			------------------------------------------------
			--To sim tha trejei gia 128+1 kykloys rologiou--
			------------------------------------------------
				
				for I in 0 to 2**7-1 loop
					CONCATENATE_IN := std_logic_vector(to_unsigned(I, CONCATENATE_IN'length));
					
					op          <= CONCATENATE_IN(6 downto 5);
					Rd          <= CONCATENATE_IN(4 downto 1);
					RegWrite_in <= CONCATENATE_IN(0);
					wait for clk_period;
					
					if (CONCATENATE_IN = "0011111") then			-- DP, Rd = 15, RegWrite_in = 1
						assert PCSrc_in = '1' report "DP PROBLEM" severity FAILURE;
					elsif (CONCATENATE_IN = "0111111") then 		-- LDR, Rd = 15, RegWrite_in = 1
						assert PCSrc_in = '1' report "LDR PROBLEM" severity FAILURE;
					elsif (op = "10" and RegWrite_in = '0') then 	-- Branch
						assert PCSrc_in = '1' report "Branch PROBLEM" severity FAILURE;
					else
						assert PCSrc_in = '0' report "Zero PROBLEM" severity FAILURE;
						
					end if;
				end loop;
			
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;


end Behavioral;
