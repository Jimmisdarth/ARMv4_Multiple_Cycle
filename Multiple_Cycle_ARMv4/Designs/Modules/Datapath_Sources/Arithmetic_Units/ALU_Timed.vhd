library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU_Timed is
	Generic (WIDTH : positive := 32);	--predifined
	Port (
		CLK        :  in STD_LOGIC;
		RESET      :  in STD_LOGIC;
		
		ALUControl :  in STD_LOGIC_VECTOR (3 downto 0);
		shamt5	   :  in STD_LOGIC_VECTOR (4 downto 0);
		
		A 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		B 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		
		ALUResult  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		Flags      : out STD_LOGIC_VECTOR (3 downto 0));
end ALU_Timed;

architecture Behavioral of ALU_Timed is
	
	Component DFF is
		generic (WIDTH : positive := 32);
		port ( 
			CLK   :  in STD_LOGIC;
			RESET :  in STD_LOGIC;
			D     :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Q     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component ALU is
		generic (WIDTH : positive := 32);	--predifined
		port (
			ALUControl :  in STD_LOGIC_VECTOR (3 downto 0);
			shamt5	   :  in STD_LOGIC_VECTOR (4 downto 0);
			
			A 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			B 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			
			ALUResult  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Flags      : out STD_LOGIC_VECTOR (3 downto 0));	
	end Component;
	
	signal A_in          : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal B_in          : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal ALUResult_in  : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal Flags_in      : STD_LOGIC_VECTOR (3 downto 0);
	
begin

	DFF_A: DFF
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => A,
			Q     => A_in
		);
		
	DFF_B: DFF
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => B,
			Q     => B_in
		);
		
	ALU_T: ALU
		generic map(
		WIDTH => WIDTH
		)
		port map(
			ALUControl => ALUControl,
			shamt5	   => shamt5,	  
			
			A 		   => A_in,
			B 		   => B_in,
			
			ALUResult  => ALUResult_in,
			Flags      => Flags_in    
		);
		
	DFF_Result: DFF
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => ALUResult_in,
			Q     => ALUResult
		);
	
	DFF_Flags: DFF
		generic map(
			WIDTH => 4
		)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => Flags_in,
			Q     => Flags
		);


end Behavioral;
