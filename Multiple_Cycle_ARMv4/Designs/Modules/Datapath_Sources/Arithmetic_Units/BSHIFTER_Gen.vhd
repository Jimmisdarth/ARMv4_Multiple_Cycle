library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BSHIFTER_Gen is
	Generic (WIDTH : positive := 32);
	Port (
		S          :  in STD_LOGIC_VECTOR (1 downto 0); -- shift select
		
		shamt      :  in STD_LOGIC_VECTOR (4 downto 0); -- shift ammount select
		
		bshift_in  :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		bshift_out : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)); 
end BSHIFTER_Gen;

architecture Behavioral of BSHIFTER_Gen is

begin

	BSHIFTER: process (S, shamt, bshift_in)
	
	variable shamt_n : NATURAL range 0 to 31;
	
	variable X_s :   SIGNED (WIDTH-1 downto 0);
	variable X_u : UNSIGNED (WIDTH-1 downto 0);
	
	begin
	
		shamt_n := to_integer(unsigned(shamt)); -- numeric_std
		
		X_s :=   signed (bshift_in); -- numeric_std
		X_u := unsigned (bshift_in); -- numeric_std
		
		case S is
		
			when "00" => 
				bshift_out <= std_logic_vector(SHIFT_LEFT (X_u, shamt_n)); 
			when "01" => 
				bshift_out <= std_logic_vector(SHIFT_RIGHT (X_u, shamt_n)); 
			when "10" => 
				bshift_out <= std_logic_vector(SHIFT_RIGHT (X_s, shamt_n)); 
			when "11" => 
				bshift_out <= std_logic_vector(ROTATE_RIGHT (X_s, shamt_n)); 
			when others => 
				bshift_out <= bshift_in;
			
		end case;
		
	end process;


end Behavioral;
