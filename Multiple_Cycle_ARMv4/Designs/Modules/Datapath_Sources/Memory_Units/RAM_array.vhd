library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RAM_array is
	Generic (
		N : positive := 5;		-- address length
		M : positive := 32);	-- data word length
	Port ( 
		CLK :  in STD_LOGIC;
		WE  :  in STD_LOGIC;
		A   :  in STD_LOGIC_VECTOR (N-1 downto 0);
		WD  :  in STD_LOGIC_VECTOR (M-1 downto 0);
		RD  : out STD_LOGIC_VECTOR (M-1 downto 0));
end RAM_array;

architecture Behavioral of RAM_array is

	type RAM_array is array (2**N-1 downto 0)
	  of STD_LOGIC_VECTOR (M-1 downto 0);
	  
	signal RAM : RAM_array;
	
begin

	Data_Memory: process (CLK)
	
	begin
	
		if (CLK = '1' and CLK'event) then
			if (WE = '1') then 
				RAM(to_integer(unsigned(A))) <= WD;
			end if;
		end if;
		
	end process;
	
	RD <= RAM(to_integer(unsigned(A)));

end Behavioral;
