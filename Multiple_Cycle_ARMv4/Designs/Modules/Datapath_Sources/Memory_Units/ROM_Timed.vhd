library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ROM_Timed is
	Generic (
		N : positive := 6;		--address length
		M : positive := 32);	--data word length
	Port (
		CLK      :  in STD_LOGIC;
		RESET    :  in STD_LOGIC;
		
		ADDR     :  in STD_LOGIC_VECTOR (N-1 downto 0);
		DATA_OUT : out STD_LOGIC_VECTOR (M-1 downto 0));
end ROM_Timed;

architecture Behavioral of ROM_Timed is
	
	Component DFF is
		generic (WIDTH : positive := 32);
		port ( 
			CLK   :  in STD_LOGIC;
			RESET :  in STD_LOGIC;
			D     :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Q     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component ROM is
		generic (
			N : positive := 6;		--address length
			M : positive := 32);	--data word length
		port (
			ADDR     :  in STD_LOGIC_VECTOR (N-1 downto 0);
			DATA_OUT : out STD_LOGIC_VECTOR (M-1 downto 0));
	end Component;
	
	signal ADDR_in     : STD_LOGIC_VECTOR (N-1 downto 0);
	signal DATA_OUT_in : STD_LOGIC_VECTOR (M-1 downto 0);
	
begin

	Input: DFF
		generic map(
			WIDTH => N
		)
		port map( 
			CLK   => CLK,  
			RESET => RESET,
			D     => ADDR,
			Q     => ADDR_in
		);
	
	Instr_Mem: ROM
		generic map(
			N => N,		
			M => M
		)	
		port map(
			ADDR     => ADDR_in,    
			DATA_OUT => DATA_OUT_in
		);
		
	Output: DFF
		generic map(
			WIDTH => M
		)
		port map( 
			CLK   => CLK,  
			RESET => RESET,
			D     => DATA_OUT_in,
			Q     => DATA_OUT
		);


end Behavioral;
