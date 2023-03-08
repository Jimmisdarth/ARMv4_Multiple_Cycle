library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is
	Generic (WIDTH : positive := 32);	--predifined
	Port (
		ALUControl :  in STD_LOGIC_VECTOR (3 downto 0);
		shamt5	   :  in STD_LOGIC_VECTOR (4 downto 0);
		
		A 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		B 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		
		ALUResult  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		Flags      : out STD_LOGIC_VECTOR (3 downto 0));	
end ALU;		

--(N, Z, C, V) == (3, 2, 1 ,0)	

architecture Behavioral of ALU is

	Component Adder_Subtractor is
		Generic (WIDTH : positive := 32);	--predifined
		Port ( 
			SUBorADD :  in STD_LOGIC;
			
			A 		 :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			B 		 :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			S 		 : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Cout 	 : out STD_LOGIC;
			OV   	 : out STD_LOGIC);
	end Component;
	
	Component And_Or_Gen is
		Generic (WIDTH : positive := 32);	--predifined value
		Port (
			Control : in STD_LOGIC;
			
			A       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			B       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			Y       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component Mov_Or_Mvn is
		generic (WIDTH : positive := 32);	--predifined
		port ( 
			Control :  in STD_LOGIC;
			
			A       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Y       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component XOR_Gate is
		generic (WIDTH : positive := 32);
		port ( 
			A :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			B :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Y : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component BSHIFTER_Gen is
		generic (WIDTH : positive := 32);
		port (
			S          :  in STD_LOGIC_VECTOR (1 downto 0); -- shift select
			
			shamt      :  in STD_LOGIC_VECTOR (4 downto 0); -- shift ammount select
			
			bshift_in  :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			bshift_out : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
	Component MUX2to1_n is
		generic (WIDTH : positive := 32); -- predifined value
		port (
			S: in STD_LOGIC;
			A0: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			A1: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Y: out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
	Component NOR_n is
		generic (WIDTH : positive := 32);
		port (
			A:  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Z: out STD_LOGIC);
	end Component;
	
	Component MUX4_in_1 is
		generic (WIDTH : positive := 32);
		port ( 
			SEL :  in STD_LOGIC_VECTOR (1 downto 0);
			
			A   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			B   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			C   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			D   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			Y   : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	signal Add_Sub_Result    : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal And_Or_Result     : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
						     
	signal Mov_Mvn_Result    : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal Xor_Result        : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
						     
	signal Shift_Result      : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	signal Arithmetic_Result : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	signal Cout : STD_LOGIC;
	signal OV   : STD_LOGIC;
	
	signal ALUResult_in : STD_LOGIC_VECTOR (WIDTH-1 downto 0);

begin

	ADD_SUB: Adder_Subtractor
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			SUBorADD => ALUControl(0),
					
			A 		 => A,
			B 		 => B,
					 
			S 		 => Add_Sub_Result,
			Cout 	 => Cout,
			OV   	 => OV
		);
		
	AND_OR: And_Or_Gen
		generic map(
			WIDTH => WIDTH
		)
		port map(
			Control => ALUControl(0),
			
			A       => A,
			B       => B,
			
			Y       => And_Or_Result
		);
		
	MOV_MVN: Mov_Or_Mvn
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			Control => ALUControl(0),
					 
			A       => B,
			Y       => Mov_Mvn_Result
		);
		
	XOR_Unit: XOR_Gate
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			A => A,
			B => B,
			Y => Xor_Result
		);
		
	Shifter: BSHIFTER_Gen
		generic map(
			WIDTH => WIDTH
		)
		port map(
			S          => ALUControl(1 downto 0),   -- shift select
			
			shamt      => shamt5, 					-- shift ammount select
			
			bshift_in  =>  B,
			bshift_out =>  Shift_Result
		);
		
	Mux_For_Arithmetic: MUX4_in_1
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			SEL => ALUControl(2 downto 1),
			
			A   => Add_Sub_Result,
			B   => And_Or_Result,
			C   => Mov_Mvn_Result,
			D   => Xor_Result,
			
			Y   => Arithmetic_Result
		);
		
	Mux_for_Arithmetic_Or_Shift: MUX2to1_n
		generic map(
			WIDTH => WIDTH
		)
		port map(
			S  => ALUControl(3),
			A0 => Arithmetic_Result,
			A1 => Shift_Result,
			Y  => ALUResult_in
		);
		
	--(N, Z, C, V) == (3, 2, 1 ,0)
		
	Flags(3) <= ALUResult_in(WIDTH-1);	-- N
	
	NOR_tree: NOR_n
		generic map(
			WIDTH => WIDTH
		)
		port map(
			A => ALUResult_in,
			Z => Flags(2)	-- Z
		);
		
	Flags(1) <= Cout and (not ALUControl(1)) and (not ALUControl(2)) and (not ALUControl(3));	-- C
	Flags(0) <= OV   and (not ALUControl(1)) and (not ALUControl(2)) and (not ALUControl(3));	-- V

	ALUResult <= ALUResult_in;

end Behavioral;
