library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity XOR_Gate is
	Generic (WIDTH : positive := 32);
	Port ( 
		A :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		B :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		Y : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end XOR_Gate;

architecture Behavioral of XOR_Gate is

begin

	Y <= A xor B;

end Behavioral;
