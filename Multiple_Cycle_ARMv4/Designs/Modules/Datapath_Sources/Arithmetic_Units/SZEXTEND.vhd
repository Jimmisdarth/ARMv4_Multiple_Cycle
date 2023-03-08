library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SZEXTEND is
	Generic (WIDTH_IN  : positive := 24;	-- predifined value 
			 WIDTH_OUT : positive := 32);	-- predifined value
	Port (
		SorZ   :  in STD_LOGIC;
		SZ_in  :  in STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0);
		SZ_out : out STD_LOGIC_VECTOR (WIDTH_OUT-1 downto 0));
end SZEXTEND;

architecture BEHAVIORAL of SZEXTEND is

begin

	SZEXTEND : process (SorZ, SZ_in)
	
	variable SZ_in_u  : UNSIGNED (11 downto 0);			--Instr11:0 gia immidiate
	variable SZ_out_u : UNSIGNED (WIDTH_OUT-1 downto 0);
	
	variable SZ_in_s  : SIGNED (25 downto 0);			--Instr23:0 &00 gia Branching
	variable SZ_out_s : SIGNED (WIDTH_OUT-1 downto 0);
	
	begin
	
		SZ_in_u := unsigned (SZ_in(11 downto 0)); 
		SZ_in_s := signed (SZ_in&"00"); 
		
		if (SorZ = '1') then 	
			-- Epektasth prosimou
			SZ_out_s := RESIZE (SZ_in_s, WIDTH_OUT);
			SZ_out <= std_logic_vector(SZ_out_s);
		else 	
			-- Epektash mhdenos
			SZ_out_u := RESIZE (SZ_in_u, WIDTH_OUT);
			SZ_out <= std_logic_vector(SZ_out_u);
		end if;
		
	end process;
	
	
end BEHAVIORAL;