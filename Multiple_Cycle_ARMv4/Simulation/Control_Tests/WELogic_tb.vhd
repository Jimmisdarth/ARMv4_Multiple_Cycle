library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity WELogic_tb is
--  Port ( );
end WELogic_tb;

architecture Behavioral of WELogic_tb is

	-- Unit Under Test (UUT)
	Component WELogic is
		port (
			NoWrite_in    :  in STD_LOGIC;
			
			op            :  in STD_LOGIC_VECTOR(1 downto 0);
			S_or_L        :  in STD_LOGIC;
			
			MemWrite_in   : out STD_LOGIC;
			FlagsWrite_in : out STD_LOGIC;
			RegWrite_in   : out STD_LOGIC);
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	
	signal NoWrite_in : STD_LOGIC := 'X';
	signal op         : STD_LOGIC_VECTOR(1 downto 0) := (others => 'X');
	signal S_or_L     : STD_LOGIC := 'X';

	-- External Outputs to UUT
	signal MemWrite_in   : STD_LOGIC;
	signal FlagsWrite_in : STD_LOGIC;
	signal RegWrite_in   : STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	
	
	type input_array is array (0 to 4) of std_logic_vector(3 downto 0);
	constant inputs : input_array := (
			"0000",	-- DP,  S = 0					op & S/L & NoWrite_in
			"0010",	-- DP,  S = 1
			"0011",	-- CMP, S = 1, NoWrite_in = 1
			"0110",	-- LDR, L = 1
			"0100" 	-- STR, L = 0
		);
		
	type response_array is array (0 to 4) of std_logic_vector(2 downto 0);
	constant response : response_array := (
			"100", -- DP,  S = 0				RegWrite_in & MemWrite_in & FlagsWrite_in
			"101", -- DP,  S = 1
			"001", -- CMP, S = 1, NoWrite_in = 1
			"100", -- LDR, L = 1
			"010"  -- STR, L = 0
		);
	
	constant all_zeroes : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');	

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: WELogic
			port map( 
				NoWrite_in    => NoWrite_in,   
                                 
				op            => op,           
				S_or_L        => S_or_L,       
				                 
				MemWrite_in   => MemWrite_in,  
				FlagsWrite_in => FlagsWrite_in,
				RegWrite_in   => RegWrite_in  
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
			
			variable found          : integer := 0;
			variable CONCATENATE    : STD_LOGIC_VECTOR(2 downto 0);
			variable CONCATENATE_IN : STD_LOGIC_VECTOR(3 downto 0);
		
			begin
				
				NoWrite_in <= '0';
				op         <= "00";
			    S_or_L     <= '0';
				wait for 10 ns;
				wait until (CLK = '0' and CLK'event);
				
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			
			------------------------------------------------
			--To sim tha trejei gia 16+1 kykloys rologiou--
			------------------------------------------------
				
				for I in 0 to 15 loop
					CONCATENATE_IN := std_logic_vector(to_unsigned(I, CONCATENATE_IN'length));
					
					op         <= CONCATENATE_IN(3 downto 2);
					S_or_L     <= CONCATENATE_IN(1);
					NoWrite_in <= CONCATENATE_IN(0);
					wait for clk_period;
					
					found := 0;
					
					for J in 0 to 4 loop
					if (op&S_or_L&NoWrite_in = inputs(J)) then 
						CONCATENATE := RegWrite_in&MemWrite_in&FlagsWrite_in;
						assert CONCATENATE = response(J) 
							report "WELogic PROBLEM" severity FAILURE;
							
						found := 1;
					end if;
					end loop;
					
					if (found = 0) then
						CONCATENATE := RegWrite_in&MemWrite_in&FlagsWrite_in;
						assert CONCATENATE = all_zeroes 
							report "Zero PROBLEM" severity FAILURE;		
					end if;
				end loop;
			
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;


end Behavioral;
