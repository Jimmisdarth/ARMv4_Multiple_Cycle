library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Thrd_Stg is
	Generic (WIDTH : positive := 32);
    Port ( 
		ALUSrc       :  in STD_LOGIC;
		ALUControl   :  in STD_LOGIC_VECTOR(3 downto 0);
					 
		SrcA         :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		WriteData_in :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		ExtImm       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		
		ALUResult_in : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		Flags_in     : out STD_LOGIC_VECTOR(3 downto 0));
end Thrd_Stg;

architecture Behavioral of Thrd_Stg is

	Component MUX2to1_n is
		generic (WIDTH : positive := 32); -- predifined value
		port (
			S: in STD_LOGIC;
			A0: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			A1: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Y: out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
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
	
	signal SrcB : STD_LOGIC_VECTOR (WIDTH-1 downto 0);

begin

	MUX_for_Register_or_Immediate: MUX2to1_n 
		generic map(
			WIDTH => WIDTH
		)
		port map(
			S  => ALUSrc,
			A0 => WriteData_in,
			A1 => ExtImm,
			Y  => SrcB
		);
		
	ALU_S: ALU
		generic map (
			WIDTH => WIDTH
		)
		port map(
			ALUControl => ALUControl,
			shamt5     => ExtImm(11 downto 7),
			
			A 		   => SrcA,
			B 		   => SrcB,
			
			ALUResult  => ALUResult_in,
			Flags      => Flags_in
		);


end Behavioral;
