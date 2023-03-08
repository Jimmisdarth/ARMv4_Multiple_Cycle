library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mov_Or_Mvn is
	Generic (WIDTH : positive := 32);	--predifined
	Port ( 
		Control :  in STD_LOGIC;
		
		A       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		Y       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end Mov_Or_Mvn;

architecture Behavioral of Mov_Or_Mvn is

begin

	process (A, Control) 
	
	begin
	
		if(Control = '0') then
			Y <= A;
		else
			Y <= not A;
		end if;
	
	end process;


end Behavioral;
