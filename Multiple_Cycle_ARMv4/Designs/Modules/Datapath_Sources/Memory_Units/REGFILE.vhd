library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REGFILE is
	generic (
		N : positive := 4;		--address length
		M : positive := 32);	--data word length
	port (
		CLK       :  in STD_LOGIC;
		
		WE	      :  in STD_LOGIC;
		ADDR_W    :  in STD_LOGIC_VECTOR (N-1 downto 0);
		
		ADDR_R1   :  in STD_LOGIC_VECTOR (N-1 downto 0);
		ADDR_R2   :  in STD_LOGIC_VECTOR (N-1 downto 0);
		
		DATA_IN   :  in STD_LOGIC_VECTOR (M-1 downto 0);
		
		DATA_OUT1 : out STD_LOGIC_VECTOR (M-1 downto 0);
		DATA_OUT2 : out STD_LOGIC_VECTOR (M-1 downto 0));
		
end REGFILE;

architecture Behavioral of REGFILE is

type RF_array is array (2**N-1 downto 0) of STD_LOGIC_VECTOR (M-1 downto 0);

signal RF: RF_array;

begin
	
	REG_FILE: process (CLK)
	
	begin
	
		if (CLK = '1' and CLK'event) then
			if (WE = '1') then
				RF(to_integer(unsigned(ADDR_W))) <= DATA_IN;
			end if;
		end if;
		
	end process;
	
	DATA_OUT1 <= RF(to_integer(unsigned(ADDR_R1)));
	DATA_OUT2 <= RF(to_integer(unsigned(ADDR_R2)));


end Behavioral;