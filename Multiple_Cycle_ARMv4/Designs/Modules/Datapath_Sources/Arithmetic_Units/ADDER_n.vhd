library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADDER_n is
	Generic (WIDTH : positive := 32);
	Port (
		A :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0); 
		B :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		S : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end ADDER_n;

architecture Behavioral of ADDER_n is

begin

	ADDER_n: process (A, B)
	
	variable A_u : UNSIGNED (WIDTH-1 downto 0);
	variable B_u : UNSIGNED (WIDTH-1 downto 0);
	variable S_u : UNSIGNED (WIDTH-1 downto 0);
	
	begin
	
		A_u := unsigned(A);
		B_u := unsigned(B);
		
		S_u := A_u + B_u;
		
		S <= std_logic_vector(S_u);
	
	end process;


end Behavioral;
