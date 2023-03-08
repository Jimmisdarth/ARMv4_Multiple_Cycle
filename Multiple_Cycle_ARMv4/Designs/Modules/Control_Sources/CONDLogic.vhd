library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CONDLogic is
	Port ( 
		cond      :  in STD_LOGIC_VECTOR(3 downto 0);
		flags     :  in STD_LOGIC_VECTOR(3 downto 0);
		
		CondEx_in : out STD_LOGIC);
end CONDLogic;

--(N, Z, C, V) == (3, 2, 1 ,0)	

architecture Behavioral of CONDLogic is

begin

	process (cond, flags)
	
		variable  N, Z, C, V : STD_LOGIC;
	
	begin
	
		N := flags(3);
		Z := flags(2);
		C := flags(1);
		V := flags(0);
	
		case cond is
			
			-- EQ
			when "0000" => 
				CondEx_in <= Z;
				
			-- NE
			when "0001" => 
				CondEx_in <= not Z;
			
			-- CS/HS
			when "0010" => 
				CondEx_in <= C;
			
			-- CC/LO
			when "0011" => 
				CondEx_in <= not C;
			
			-- MI
			when "0100" => 
				CondEx_in <= N;
			
			-- PL
			when "0101" => 
				CondEx_in <= not N;
			
			-- VS
			when "0110" => 
				CondEx_in <= V;
			
			-- VC
			when "0111" => 
				CondEx_in <= not V;
			
			-- HI
			when "1000" => 
				CondEx_in <= (not Z) and C;
			
			-- LS
			when "1001" => 
				CondEx_in <= Z or (not C);
			
			-- GE
			when "1010" => 
				CondEx_in <= not (N xor V);
			
			-- LT
			when "1011" => 
				CondEx_in <= N xor V;
			
			-- GT
			when "1100" => 
				CondEx_in <= (not Z) and (not (N xor V));
			
			-- LE
			when "1101" => 
				CondEx_in <= Z or (N xor V);
			
			-- Al
			when "1110" => 
				CondEx_in <= '1';
			
			-- For uncoditional instrucrions
			when "1111" => 
				CondEx_in <= '1';
			
			-- default state
			when others =>
				CondEx_in <= '0';
				
			
		end case;
	
	end process;


end Behavioral;
