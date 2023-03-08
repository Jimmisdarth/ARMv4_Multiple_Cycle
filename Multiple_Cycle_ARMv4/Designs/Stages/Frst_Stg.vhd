library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Frst_Stg is
	Generic (
		N     : positive := 6; 	  --address length
		WIDTH : positive := 32);  --data word length
	Port (
		PC_in     :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		
		Instr     : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		PCPlus4   : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end Frst_Stg;

architecture Behavioral of Frst_Stg is

	Component ROM is
		Generic (
			N : positive := 6;		--address length
			M : positive := 32);	--data word length
		Port (
			ADDR     :  in STD_LOGIC_VECTOR (N-1 downto 0);
			DATA_OUT : out STD_LOGIC_VECTOR (M-1 downto 0));
	end Component;
	
	Component ADDER_n is
		Generic (WIDTH : positive := 32);
		Port (
			A :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0); 
			B :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			S : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
begin

	InstructionMemory: ROM
		generic map(
			N => N,
			M => WIDTH
		)
		port map(
			ADDR     => PC_in(N+1 downto 2),
			DATA_OUT => Instr
		);
		
	INC4: ADDER_n 
		generic map(
			WIDTH => WIDTH
		)
		port map(
			A => PC_in, 
			B => x"00000004",
			S => PCPlus4
		);


end Behavioral;
