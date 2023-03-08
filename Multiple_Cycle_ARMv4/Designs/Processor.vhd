library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Processor is
	Generic (WIDTH : positive := 32);
	Port (
		CLK 		:  in STD_LOGIC;
		RESET       :  in STD_LOGIC;
		
		PC 			: out STD_LOGIC_VECTOR(WIDTH-17 downto 0);
		Instruction : out STD_LOGIC_VECTOR(WIDTH-1  downto 0);
		ALUResult   : out STD_LOGIC_VECTOR(WIDTH-1  downto 0);
		WriteData   : out STD_LOGIC_VECTOR(WIDTH-1  downto 0);
		Result      : out STD_LOGIC_VECTOR(WIDTH-1  downto 0));
end Processor;

architecture Behavioral of Processor is

	Component Control is
		port ( 
			CLK         :  in STD_LOGIC;
			RESET       :  in STD_LOGIC;
			
			Instruction :  in STD_LOGIC_VECTOR(31 downto 20);
			Rd			:  in STD_LOGIC_VECTOR(3 downto 0);		-- Instr 15:12
			sh			:  in STD_LOGIC_VECTOR(1 downto 0);		-- Instr 6:5
			Flags       :  in STD_LOGIC_VECTOR(3 downto 0);
			
			IRWrite		: out STD_LOGIC;
			
			RegSrc      : out STD_LOGIC_VECTOR(2 downto 0);
			RegWrite    : out STD_LOGIC;
			ImmSrc      : out STD_LOGIC;
						
			ALUSrc      : out STD_LOGIC;
			ALUControl  : out STD_LOGIC_VECTOR(3 downto 0);
			FlagsWrite  : out STD_LOGIC;
			
			MAWrite		: out STD_LOGIC;
			
			MemWrite    : out STD_LOGIC;
						
			MemtoReg    : out STD_LOGIC;
			PCSrc	    : out STD_LOGIC_VECTOR(1 downto 0);
			PCWrite     : out STD_LOGIC);
	end Component;
	
	Component Datapath is
		generic (WIDTH : positive := 32);	--World Length
		port (
			CLK		    :  in STD_LOGIC;
			RESET       :  in STD_LOGIC;
						
			PCWrite     :  in STD_LOGIC;
			
			IRWrite     :  in STD_LOGIC;
						
			RegSrc      :  in STD_LOGIC_VECTOR(2 downto 0);
			RegWrite    :  in STD_LOGIC;
			ImmSrc      :  in STD_LOGIC;
						
			ALUSrc      :  in STD_LOGIC;
			ALUControl  :  in STD_LOGIC_VECTOR(3 downto 0);
			FlagsWrite  :  in STD_LOGIC;
			
			MAWrite		:  in STD_LOGIC;
						
			MemWrite    :  in STD_LOGIC;
						
			MemtoReg    :  in STD_LOGIC;
			PCSrc	    :  in STD_LOGIC_VECTOR(1 downto 0);
						
			PC		    : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Instruction : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			ALUResult   : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Writedata   : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Result      : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			Flags       : out STD_LOGIC_VECTOR(3 downto 0));
	end Component;
			
	signal Flags_in       : STD_LOGIC_VECTOR(3 downto 0);
	
	signal IRWrite_in	  : STD_LOGIC;
 
	signal RegSrc_in      : STD_LOGIC_VECTOR(2 downto 0);
	signal RegWrite_in    : STD_LOGIC;
	signal ImmSrc_in      : STD_LOGIC;
 			
	signal ALUSrc_in      : STD_LOGIC;
	signal ALUControl_in  : STD_LOGIC_VECTOR(3 downto 0);
	signal FlagsWrite_in  : STD_LOGIC;

	signal MAWrite_in	  : STD_LOGIC;
 
	signal MemWrite_in    : STD_LOGIC;
 			
	signal MemtoReg_in    : STD_LOGIC;
	signal PCSrc_in	      : STD_LOGIC_VECTOR(1 downto 0);
	signal PCWrite_in     : STD_LOGIC;
	
	signal PC_in		  : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
	signal Instruction_in : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
	signal ALUResult_in   : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
	signal Writedata_in   : STD_LOGIC_VECTOR(WIDTH-1 downto 0);
	signal Result_in      : STD_LOGIC_VECTOR(WIDTH-1 downto 0);	
	
begin

	Controller: Control
		port map( 
			CLK         => CLK,
			RESET       => RESET,
			
			Instruction => Instruction_in(31 downto 20),
			Rd			=> Instruction_in(15 downto 12),
			sh			=> Instruction_in(6 downto 5),	-- Instr 6:5
			Flags       => Flags_in,
			
			IRWrite		=> IRWrite_in,
			
			RegSrc      => RegSrc_in,
			RegWrite    => RegWrite_in,
			ImmSrc      => ImmSrc_in,
						
			ALUSrc      => ALUSrc_in,
			ALUControl  => ALUControl_in,
			FlagsWrite  => FlagsWrite_in,
			
			MAWrite		=> MAWrite_in,
			
			MemWrite    => MemWrite_in,
						
			MemtoReg    => MemtoReg_in,
			PCSrc	    => PCSrc_in,
			PCWrite     => PCWrite_in
		);
	
	
	Datapath_Unit: Datapath
		generic map(
			WIDTH => WIDTH	--World Length
		)	
		port map(
			CLK		    => CLK,
			RESET       => RESET,
						
			PCWrite     => PCWrite_in,
			
			IRWrite     => IRWrite_in,
						
			RegSrc      => RegSrc_in,
			RegWrite    => RegWrite_in,
			ImmSrc      => ImmSrc_in,
						
			ALUSrc      => ALUSrc_in,
			ALUControl  => ALUControl_in,
			FlagsWrite  => FlagsWrite_in,
			
			MAWrite		=> MAWrite_in,
						
			MemWrite    => MemWrite_in,
						
			MemtoReg    => MemtoReg_in,
			PCSrc	    => PCSrc_in,
						
			PC		    => PC_in,		   
			Instruction => Instruction_in,
			ALUResult   => ALUResult_in,  
			Writedata   => Writedata_in,  
			Result      => Result_in,     
			
			Flags       => Flags_in    
		);
		
	PC 			<= PC_in(15 downto 0);
	Instruction <= Instruction_in;
	ALUResult   <= ALUResult_in;
	Writedata   <= Writedata_in;
	Result      <= Result_in;


end Behavioral;
