library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity And_Or_Gen is
	Generic (WIDTH : positive := 32);	--predifined value
	Port (
		Control : in STD_LOGIC;
		
		A       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		B       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		
		Y       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end And_Or_Gen;

architecture Behavioral of And_Or_Gen is

begin

	process (A, B, Control)
	
	begin
	
		if(Control = '0') then
			Y <= A and B;
		else
			Y <= A or B;
		end if;
	
	end process;


end Behavioral;
