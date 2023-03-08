library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;


entity CONDLogic_tb is
--  Port ( );
end CONDLogic_tb;

architecture Behavioral of CONDLogic_tb is

	-- Unit Under Test (UUT)
	Component CONDLogic is
		port ( 
			cond      :  in STD_LOGIC_VECTOR(3 downto 0);
			flags     :  in STD_LOGIC_VECTOR(3 downto 0);
			
			CondEx_in : out STD_LOGIC);
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	
	signal cond  : STD_LOGIC_VECTOR(3 downto 0) := (others => 'X');
	signal flags : STD_LOGIC_VECTOR(3 downto 0) := (others => 'X');

	-- External Outputs to UUT
	signal CondEx_in : STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: CONDLogic
			port map( 
				cond      => cond,     
				flags     => flags,    
						     		
				CondEx_in => CondEx_in
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
			
			variable CONCATENATE_IN : STD_LOGIC_VECTOR(7 downto 0);
			variable N, Z, C, V     : STD_LOGIC;
		
			begin
				
				cond  <= "0000";
			    flags <= "0000";
				wait for 10 ns;
				wait until (CLK = '0' and CLK'event);
				
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			
			------------------------------------------------
			--To sim tha trejei gia 256+1 kykloys rologiou--
			------------------------------------------------
				
				for I in 0 to 2**8-1 loop
					CONCATENATE_IN := std_logic_vector(to_unsigned(I, CONCATENATE_IN'length));
					
					cond  <= CONCATENATE_IN(7 downto 4);
					flags <= CONCATENATE_IN(3 downto 0);
					wait for clk_period;
					
					N := flags(3);
					Z := flags(2);
					C := flags(1);
					V := flags(0);
					
					if    (cond = "0000" and Z = '1') then
						assert CondEx_in = '1' report "EQ PROBLEM" severity FAILURE;
						
					elsif (cond = "0001" and Z = '0') then 
						assert CondEx_in = '1' report "NE PROBLEM" severity FAILURE;
						
					elsif (cond = "0010" and C = '1') then
						assert CondEx_in = '1' report "CS PROBLEM" severity FAILURE;
					
					elsif (cond = "0011" and C = '0') then
						assert CondEx_in = '1' report "CC PROBLEM" severity FAILURE;
						
					elsif (cond = "0100" and N = '1') then
						assert CondEx_in = '1' report "MI PROBLEM" severity FAILURE;
						
					elsif (cond = "0101" and N = '0') then
						assert CondEx_in = '1' report "PL PROBLEM" severity FAILURE;
					
					elsif (cond = "0110" and V = '1') then
						assert CondEx_in = '1' report "VS PROBLEM" severity FAILURE;
						
					elsif (cond = "0111" and V = '0') then
						assert CondEx_in = '1' report "VC PROBLEM" severity FAILURE;
					
					elsif (cond = "1000" and Z = '0' and C = '1') then
						assert CondEx_in = '1' report "HI PROBLEM" severity FAILURE;
						
					elsif (cond = "1001" and (Z = '1' or C = '0')) then
						assert CondEx_in = '1' report "LS PROBLEM" severity FAILURE;
						
					elsif (cond = "1010" and (N xor V) = '0') then
						assert CondEx_in = '1' report "GE PROBLEM" severity FAILURE;
						
					elsif (cond = "1011" and (N xor V) = '1') then
						assert CondEx_in = '1' report "LT PROBLEM" severity FAILURE;
						
					elsif (cond = "1100" and (Z = '0' and (N xor V) = '0')) then
						assert CondEx_in = '1' report "GT PROBLEM" severity FAILURE;
					
					elsif (cond = "1101" and (Z = '1' or (N xor V) = '1')) then
						assert CondEx_in = '1' report "LE PROBLEM" severity FAILURE;
						
					elsif (cond = "1110") then
						assert CondEx_in = '1' report "Al PROBLEM" severity FAILURE;
					
					elsif (cond = "1111") then
						assert CondEx_in = '1' report "none PROBLEM" severity FAILURE;
					
					else
						assert CondEx_in = '0' report "CondEx PROBLEM" severity FAILURE;
						
					end if;					
							
				end loop;
			
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;



end Behavioral;
