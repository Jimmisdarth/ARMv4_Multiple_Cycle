library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Adder_Subtractor is
	Generic (WIDTH : positive := 32);	--predifined
	Port ( 
		SUBorADD :  in STD_LOGIC;
		
		A 		 :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		B 		 :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		
		S 		 : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		Cout 	 : out STD_LOGIC;
		OV   	 : out STD_LOGIC);
end Adder_Subtractor;

architecture Behavioral of Adder_Subtractor is

begin

	process (A, B, SUBorADD)
	
	variable A_s : SIGNED (WIDTH+1 downto 0);
	variable B_s : SIGNED (WIDTH+1 downto 0);
	variable S_s : SIGNED (WIDTH+1 downto 0);
	
	begin
	
		A_s := signed('0'&A(WIDTH-1)&A);
		B_s := signed('0'&B(WIDTH-1)&B);
		
		if (SUBorADD = '0') then
			S_s := A_s + B_s;
		else
			S_s := A_s - B_s;
		end if;
		
		S    <= std_logic_vector(S_s(WIDTH-1 downto 0));
		OV 	 <= S_s(WIDTH) xor S_s(WIDTH-1);
		Cout <= S_s(WIDTH+1);
	
	end process;


end Behavioral;
