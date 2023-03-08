library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUX3_in_1 is
	Generic (WIDTH : positive := 32);
	Port ( 
		SEL :  in STD_LOGIC_VECTOR (1 downto 0);
		
		A   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		B   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		C   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		
		Y   : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end MUX3_in_1;

architecture Behavioral of MUX3_in_1 is

begin

	process (SEL, A, B, C)
	
	begin
	
		case SEL is
		
			when "00" => 
				Y <= A;
			when "11" => 
				Y <= B;
			when "10" => 
				Y <= C;
			when others => 
				Y <= (others => '0');
			
		end case;
		
	end process;


end Behavioral;
