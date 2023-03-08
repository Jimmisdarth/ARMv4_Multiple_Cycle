library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity REGgenrwe is
	Generic (WIDTH : positive := 32);
	Port (
		CLK   : in STD_LOGIC;
		RESET : in STD_LOGIC;
		WE    : in STD_LOGIC;
		D     : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		Q     :out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end REGgenrwe;

architecture Behavioral of REGgenrwe is

begin

	process (CLK)
	
	begin
	
		if (CLK = '1' and CLK'event) then
		
			if (RESET = '1') then
				Q <= (others => '0');
			elsif (WE = '1') then
				Q <= D;
			end if;
		end if;
	
	end process;

end Behavioral;
