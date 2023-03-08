library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RegisterFile_Timed is
	generic (
			N : positive := 4;		--address length
			M : positive := 32);	--data word length
	port (
		CLK      :  in STD_LOGIC;
		RESET	 :  in STD_LOGIC;
		
		RegWrite :  in STD_LOGIC;
		
		A1    	 :  in STD_LOGIC_VECTOR (N-1 downto 0);
		A2    	 :  in STD_LOGIC_VECTOR (N-1 downto 0);
		A3    	 :  in STD_LOGIC_VECTOR (N-1 downto 0);
			 
		WD3   	 :  in STD_LOGIC_VECTOR (M-1 downto 0);
			 
		R15   	 :  in STD_LOGIC_VECTOR (M-1 downto 0);
			 
		RD1   	 : out STD_LOGIC_VECTOR (M-1 downto 0);
		RD2   	 : out STD_LOGIC_VECTOR (M-1 downto 0));
end RegisterFile_Timed;

architecture Behavioral of RegisterFile_Timed is
	
	Component DFF is
		generic (WIDTH : positive := 32);
		port ( 
			CLK   :  in STD_LOGIC;
			RESET :  in STD_LOGIC;
			D     :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Q     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
		
	Component RegisterFile is
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
	end Component;
	
	
	signal A1_in  : STD_LOGIC_VECTOR (N-1 downto 0);
	signal A2_in  : STD_LOGIC_VECTOR (N-1 downto 0);
	signal A3_in  : STD_LOGIC_VECTOR (N-1 downto 0);

	signal WD3_in : STD_LOGIC_VECTOR (M-1 downto 0);
 	
	signal R15_in : STD_LOGIC_VECTOR (M-1 downto 0);
 	
	signal RD1_in : STD_LOGIC_VECTOR (M-1 downto 0);
	signal RD2_in : STD_LOGIC_VECTOR (M-1 downto 0);
	
	
begin
	
	DFF_A1: DFF
		generic map(
			WIDTH => N
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => A1,
			Q     => A1_in
		);
	
	DFF_A2: DFF
		generic map(
			WIDTH => N
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => A2,
			Q     => A2_in
		);
	
	DFF_A3: DFF
		generic map(
			WIDTH => N
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => A3,
			Q     => A3_in
		);
	
	DFF_WD3: DFF
		generic map(
			WIDTH => M
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => WD3,
			Q     => WD3_in
		);
		
	DFF_R15: DFF
		generic map(
			WIDTH => M
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => R15,
			Q     => R15_in
		);

	RegFile: RegisterFile
		generic map(
				N => N,		
				M => M
		)	
		port map(
			CLK      => CLK,
			
			RegWrite => RegWrite,
			
			A1    	 => A1_in,
			A2    	 => A2_in,
			A3    	 => A3_in,
				
			WD3   	 => WD3_in, 
				
			R15   	 => R15_in,
				
			RD1   	 => RD1_in,
			RD2   	 => RD2_in
		);
	
	DFF_RD1: DFF
		generic map(
			WIDTH => M
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => RD1_in,
			Q     => RD1
		);
	
	DFF_RD2: DFF
		generic map(
			WIDTH => M
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => RD2_in,
			Q     => RD2
		);

end Behavioral;
