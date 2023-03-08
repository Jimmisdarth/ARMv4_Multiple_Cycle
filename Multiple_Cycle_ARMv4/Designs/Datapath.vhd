library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath is
	Generic (WIDTH : positive := 32);	--World Length
	Port (
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
end Datapath;

architecture Behavioral of Datapath is
	
	constant N 				   : positive := 6;		--gia thn IM wste na xwraei 64 entoles
	constant ADDRESS_LENGTH    : positive := 4;	    --gia ta mux pou pane sto RF
	
	Component REGgenrwe is
		Generic (WIDTH : positive := 32);
		Port (
			CLK   : in STD_LOGIC;
			RESET : in STD_LOGIC;
			WE    : in STD_LOGIC;
			D     : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Q     :out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
	Component DFF is
		generic (WIDTH : positive := 32);
		port ( 
			CLK   :  in STD_LOGIC;
			RESET :  in STD_LOGIC;
			D     :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Q     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component Frst_Stg is
		generic (
			N     : positive := 6; 	  --address length
			WIDTH : positive := 32);  --data word length
		port (
			PC_in     :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Instr     : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			PCPlus4   : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
	Component Scnd_Stg is
		generic (
			N     : positive := 4;		--address length
			WIDTH : positive := 32);	--data word length
		port (
			CLK          : in STD_LOGIC;
			
			RegSrc       :  in STD_LOGIC_VECTOR(2 downto 0);
			RegWrite     :  in STD_LOGIC;
			ImmSrc       :  in STD_LOGIC;
						
			Instr        :  in STD_LOGIC_VECTOR(23 downto 0);
			PCPlus4      :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Result_in    :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
						
			RD1          : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			RD2 		 : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			ExtImm       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	Component Thrd_Stg is
		generic (WIDTH : positive := 32);
		port ( 
			ALUSrc       :  in STD_LOGIC;
			ALUControl   :  in STD_LOGIC_VECTOR(3 downto 0);
						
			SrcA         :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			WriteData_in :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			ExtImm       :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			ALUResult_in : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			Flags_in     : out STD_LOGIC_VECTOR(3 downto 0));
		end Component;
	
	Component RAM_array is
		Generic (
			N : positive := 5;		-- address length
			M : positive := 32);	-- data word length
		Port ( 
			CLK :  in STD_LOGIC;
			WE  :  in STD_LOGIC;
			A   :  in STD_LOGIC_VECTOR (N-1 downto 0);
			WD  :  in STD_LOGIC_VECTOR (M-1 downto 0);
			RD  : out STD_LOGIC_VECTOR (M-1 downto 0));
	end Component;
	
	Component Fth_Stg is
		generic(WIDTH : positive := 32);
		port (
			MemtoReg     :  in STD_LOGIC;
			PCSrc	     :  in STD_LOGIC_VECTOR(1 downto 0);
			
			ALUResult    :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			S_in		 :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			RD           :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			PCPlus4      :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			Result       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			PCN          : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	signal PCN          : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo to 1o bhma
	signal PC_in         : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal Instr_in      : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal PCPlus4_in    : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo tous Reg tou 1o bhmatos
	signal Instr_out     : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal PCPlus4_out   : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo to 2o bhma
	signal RD1           : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal RD2           : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal ExtImm_in     : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo tous Reg tou 2o bhmatos
	signal SrcA		     : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal WriteData_in  : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal ExtImm_out	 : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo to 3o bhma
	signal ALUResult_in  : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal Flags_in      : STD_LOGIC_VECTOR (3 downto 0);
	
	-- Outputs apo tous Reg tou 3o bhmatos
	signal A_in			 : STD_LOGIC_VECTOR (4 downto 0);
	signal WriteData_out : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal ALUResult_out : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo to 4o bhma
	signal RD_in		 : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	-- Outputs apo to Reg tou 4o bhmatos
	signal RD_out		 : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	
	signal Result_in : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	

begin

	ProgramCounter: REGgenrwe
		generic map(
			WIDTH => WIDTH
		)
		port map(
			CLK   => CLK,
			RESET => RESET,
			WE    => PCWrite,
			D     => PCN,
			Q     => PC_in
		);
		
	PC <= PC_in;
		

	-- BHMA 1o

	First_Stage: Frst_Stg
		generic map(
			N     => N,
			WIDTH => WIDTH
		)
		port map(
			PC_in   => PC_in,
			Instr   => Instr_in,
			PCPlus4 => PCPlus4_in
		);
		
	
	-------------------------------
	-------------------------------
	
	Instruction_Register: REGgenrwe
		generic map(WIDTH => WIDTH)
		port map(
			CLK   => CLK,   
			RESET => RESET,
			WE    => IRWrite,
			D     => Instr_in,
			Q     => Instr_out
		);
		
	
	-------------------------------
	-------------------------------
	
	PCPlus4_Register: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => PCPlus4_in,
			Q     => PCPlus4_out
		);
	
	
	-------------------------------
	-------------------------------
	
	
	Instruction <= Instr_in;
		
		
	-- BHMA 2o
	
	
	Second_Stage: Scnd_Stg
		generic map(
			N     => ADDRESS_LENGTH,		
			WIDTH => WIDTH
		)
		port map(
			CLK          => CLK,
						 
			RegSrc       => RegSrc,  
			RegWrite     => RegWrite,
			ImmSrc       => ImmSrc,  
						
			Instr        => Instr_out(23 downto 0),    
			PCPlus4      => PCPlus4_out,  
			Result_in    => Result_in,	
						
			RD1          => RD1,        
			RD2 		 => RD2,
			ExtImm       => ExtImm_in      
		); 
		
	
	-------------------------------
	-------------------------------
	
	A: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => RD1,
			Q     => SrcA
		);
	
	
	-------------------------------
	-------------------------------
	
	B: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => RD2,
			Q     => WriteData_in
		);
	
	
	-------------------------------
	-------------------------------
	
	
	I: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => ExtImm_in,
			Q     => ExtImm_out
		);
	
	
	-------------------------------
	-------------------------------
	
	WriteData <= WriteData_in;
		
	
	-- BHMA 3o
	
	
	Third_Stage: Thrd_Stg
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			ALUSrc       => ALUSrc,    
			ALUControl   => ALUControl,
						
			SrcA         => SrcA,        
			WriteData_in => WriteData_in,
			ExtImm       => ExtImm_out,      
			
			ALUResult_in => ALUResult_in,
			Flags_in     => Flags_in
		);
		
		
	-----------------------------	
	-----------------------------
	
	Status_Register: REGgenrwe
		generic map(
			WIDTH => 4
		)
		port map(
			CLK   => CLK,
			RESET => RESET,
			WE    => FlagsWrite,
			D     => Flags_in,
			Q     => Flags
		);
	
	------------------------------
	------------------------------
	
	ALUResult <= ALUResult_in;
	
	-------------------------------
	-------------------------------
	
	
	MA: REGgenrwe
		generic map(
			WIDTH => 5
		)
		port map(
			CLK   => CLK,
			RESET => RESET,
			WE    => MAWrite,
			D     => ALUResult_in(6 downto 2),
			Q     => A_in
		);
	
	
	-------------------------------
	-------------------------------
	
	
	WD: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => WriteData_in,
			Q     => WriteData_out
		);
		
	
	-------------------------------
	-------------------------------
	
	S: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => ALUResult_in,
			Q     => ALUResult_out
		);
	
	
	-------------------------------
	-------------------------------
	
	
	-- BHMA 4o
	
	
	Fourth_Stage: RAM_array
		generic map(
			N => 5,	      -- address length
			M => WIDTH    -- data word length
		)
		port map( 
			CLK => CLK,
			WE  => MemWrite,
			A   => A_in,
			WD  => WriteData_out,
			RD  => RD_in
		);
		
	-------------------------------
	-------------------------------
	
	RD: DFF
		generic map(WIDTH => WIDTH)
		port map( 
			CLK   => CLK,
			RESET => RESET,
			D     => RD_in,
			Q     => RD_out
		);
	
	
	-------------------------------
	-------------------------------
	
	
	-- BHMA 5o
	
	
	Fifth_Stage: Fth_Stg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			MemtoReg     => MemtoReg,
			PCSrc	     => PCSrc,

			ALUResult    => ALUResult_in,
			S_in		 => ALUResult_out,
			RD           => RD_out,
			PCPlus4      => PCPlus4_out,

			Result       => Result_in,
			PCN          => PCN
		);
		
	Result <= Result_in;


end Behavioral;
