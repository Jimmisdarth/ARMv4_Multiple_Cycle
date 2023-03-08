library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NOR_n is
    generic (WIDTH : positive := 32);
    port (
		A:  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		Z: out STD_LOGIC);
end NOR_n;

architecture STRUCTURAL of NOR_n is

	signal X : STD_LOGIC_VECTOR (WIDTH downto 0);

begin

	X(0) <= '0';
	
	G1: for I in 0 to WIDTH-1 generate
		X(I+1) <= X(I) or A(I);
		Z <= not X(WIDTH);
	end generate G1;

end STRUCTURAL;
