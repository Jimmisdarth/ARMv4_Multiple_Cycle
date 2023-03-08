library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control is
	Port ( 
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
end Control;

architecture Behavioral of Control is

	Component InstrDec is
		port ( 
			op          :  in STD_LOGIC_VECTOR(1 downto 0);		-- Instr(27:26)
			funct       :  in STD_LOGIC_VECTOR(5 downto 0);		-- Instr(25:20)
			sh          :  in STD_LOGIC_VECTOR(1 downto 0);		-- Instr(6:5)
			
			RegSrc      : out STD_LOGIC_VECTOR(2 downto 0);
			ALUSrc      : out STD_LOGIC;
			MemtoReg    : out STD_LOGIC;
			ALUControl  : out STD_LOGIC_VECTOR(3 downto 0);
			ImmSrc      : out STD_LOGIC;
			
			NoWrite_in  : out STD_LOGIC);
	end Component;
	
	Component FSM is
		port ( 
			CLK   	   :  in STD_LOGIC;
			RESET 	   :  in STD_LOGIC;
			
			op		   :  in STD_LOGIC_VECTOR(1 downto 0);	--Instr(27:26)
			S_or_L     :  in STD_LOGIC;						--Instr(20)
			Rd         :  in STD_LOGIC_VECTOR(3 downto 0);	--Instr(15:12)
			Link	   :  in STD_LOGIC;						--Instr(24)
			
			NoWrite_in :  in STD_LOGIC;
			CondEx_in  :  in STD_LOGIC;
			
			IRWrite    : out STD_LOGIC;
			RegWrite   : out STD_LOGIC;
			MAWrite    : out STD_LOGIC;
			MemWrite   : out STD_LOGIC;
			FlagsWrite : out STD_LOGIC;
			PCSrc      : out STD_LOGIC_VECTOR(1 downto 0);
			PCWrite    : out STD_LOGIC);
	end Component;
	
	Component CONDLogic is
		port ( 
			cond      :  in STD_LOGIC_VECTOR(3 downto 0);
			flags     :  in STD_LOGIC_VECTOR(3 downto 0);
			
			CondEx_in : out STD_LOGIC);
	end Component;
	
	signal NoWrite_in : STD_LOGIC;
	signal CondEx_in : STD_LOGIC;

begin

	Instruction_Decoder: InstrDec
		port map( 
			op          => Instruction(27 downto 26),        
			funct       => Instruction(25 downto 20),
			sh			=> sh,
                           
			RegSrc      => RegSrc,    
			ALUSrc      => ALUSrc,    
			MemtoReg    => MemtoReg,  
			ALUControl  => ALUControl,
			ImmSrc      => ImmSrc,    
                           
			NoWrite_in  => NoWrite_in
		); 
		
	Moore_FSM: FSM
		port map( 
			CLK   	   => CLK,   
			RESET 	   => RESET, 
			
			op		   =>  Instruction(27 downto 26),	--Instr(27:26)
			S_or_L     =>  Instruction(20),				--Instr(20)
			Rd         =>  Rd,
			Link	   =>  Instruction(24),				--Instr(24)
			
			NoWrite_in => NoWrite_in,
			CondEx_in  => CondEx_in, 
			
			IRWrite    => IRWrite,   
			RegWrite   => RegWrite,  
			MAWrite    => MAWrite,   
			MemWrite   => MemWrite,  
			FlagsWrite => FlagsWrite,
			PCSrc      => PCSrc,     
			PCWrite    => PCWrite
		);
		
	Condition_Logic: CONDLogic
		port map( 
			cond      => Instruction(31 downto 28),
			flags     => Flags,
					   
			CondEx_in => CondEx_in
		);


end Behavioral;
