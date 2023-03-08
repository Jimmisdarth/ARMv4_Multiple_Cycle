library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUX2to1_n is
	generic (WIDTH : positive := 32); -- predifined value
	port (
		S: in STD_LOGIC;
		A0: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		A1: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		Y: out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end MUX2to1_n;

architecture BEHAVIORAL of MUX2to1_n is

begin

	process (A0, A1, S)
	
	begin
	
		if (S = '0') then
			Y <= A0;
		else
			Y <= A1;
		end if;
		
	end process;
	
end BEHAVIORAL;
