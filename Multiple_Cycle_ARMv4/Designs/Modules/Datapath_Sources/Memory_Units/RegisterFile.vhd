library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RegisterFile is
	generic (
			N : positive := 4;		--address length
			M : positive := 32);	--data word length
	port (
		CLK      :  in STD_LOGIC;
		
		RegWrite :  in STD_LOGIC;
		
		A1    	 :  in STD_LOGIC_VECTOR (N-1 downto 0);
		A2    	 :  in STD_LOGIC_VECTOR (N-1 downto 0);
		A3    	 :  in STD_LOGIC_VECTOR (N-1 downto 0);
			 
		WD3   	 :  in STD_LOGIC_VECTOR (M-1 downto 0);
			 
		R15   	 :  in STD_LOGIC_VECTOR (M-1 downto 0);
			 
		RD1   	 : out STD_LOGIC_VECTOR (M-1 downto 0);
		RD2   	 : out STD_LOGIC_VECTOR (M-1 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

	Component REGFILE is
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
		
	end Component;
	
	signal RF_RD1 : STD_LOGIC_VECTOR (M-1 downto 0);
	signal RF_RD2 : STD_LOGIC_VECTOR (M-1 downto 0);
	
begin

	RF_RO_to_R14: REGFILE
		generic map(
			N => N,
			M => M
		)
		port map(
			CLK       => CLK,
			
			WE	      => RegWrite,
			ADDR_W    => A3,
			
			ADDR_R1   => A1,
			ADDR_R2   => A2,
			
			DATA_IN   => WD3,
			
			DATA_OUT1 => RF_RD1,
			DATA_OUT2 => RF_RD2
		);
		
	Mux_For_RD1: process (RF_RD1, R15, A1)
	
	begin
	
		if (A1 = "1111") then
			RD1 <= R15;
		else
			RD1 <= RF_RD1;
		end if;
	
	end process;
	
	Mux_For_RD2: process (RF_RD2, R15, A2)
	
	begin
	
		if (A2 = "1111") then
			RD2 <= R15;
		else
			RD2 <= RF_RD2;
		end if;
	
	end process;


end Behavioral;
