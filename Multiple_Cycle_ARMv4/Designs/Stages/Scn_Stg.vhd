library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Scnd_Stg is
	Generic (
		N     : positive := 4;		--address length
		WIDTH : positive := 32);	--data word length
	Port (
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
end Scnd_Stg;

architecture Behavioral of Scnd_Stg is

	constant WIDTH_IN       : positive := 24;	--gia to Extend

	Component MUX2to1_n is
		generic (WIDTH : positive := 32); -- predifined value
		port (
			S: in STD_LOGIC;
			A0: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			A1: in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Y: out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;

	Component ADDER_n is
		Generic (WIDTH : positive := 32);
		Port (
			A :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0); 
			B :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			S : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
	Component RegisterFile is
		Generic (
				N : positive := 4;		--address length
				M : positive := 32);	--data word length
		Port (
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
	
	Component SZEXTEND is
		Generic (WIDTH_IN  : positive := 24;	-- predifined value 
				 WIDTH_OUT : positive := 32);	-- predifined value
		Port (
			SorZ   :  in STD_LOGIC;
			SZ_in  :  in STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0);
			SZ_out : out STD_LOGIC_VECTOR (WIDTH_OUT-1 downto 0));
	end Component;
	
	signal RA1 	     : STD_LOGIC_VECTOR (N-1 downto 0);
	signal RA2 	     : STD_LOGIC_VECTOR (N-1 downto 0);
	signal WA  	     : STD_LOGIC_VECTOR (N-1 downto 0);
	signal PCPlus8   : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal WD3       : STD_LOGIC_VECTOR (WIDTH-1 downto 0);

begin

	INC8: ADDER_n 
		generic map(
			WIDTH => WIDTH
		)
		port map(
			A => x"00000004", 
			B => PCPlus4,
			S => PCPlus8
		);
	
	Mux_for_Rn_or_R15: MUX2to1_n 
		generic map(
			WIDTH => N
		)
		port map(
			S  => RegSrc(0),
			A0 => Instr(19 downto 16),
			A1 => x"F",		--R15
			Y  => RA1
		);
	
	Mux_for_Rm_or_Rd: MUX2to1_n 
		generic map(
			WIDTH => N
		)
		port map(
			S  => RegSrc(1),
			A0 => Instr(3 downto 0),
			A1 => Instr(15 downto 12),
			Y  => RA2
		);
	
	Mux_for_Rd_or_R14: MUX2to1_n 
		generic map(
			WIDTH => N
		)
		port map(
			S  => RegSrc(2),
			A0 => Instr(15 downto 12),
			A1 => x"E",		--R14
			Y  => WA
		);
		
	Mux_for_INC4_or_Result: MUX2to1_n 
		generic map(
			WIDTH => WIDTH
		)
		port map(
			S  => RegSrc(2),
			A0 => Result_in,	--edw tha mpei to Result
			A1 => PCPlus4,
			Y  => WD3
		);
	
	RegFile: RegisterFile
		generic map(
			N => N,			--address length
			M => WIDTH		--data word length
		)
		port map(
			CLK      => CLK,
					 
			RegWrite => RegWrite,
					
			A1    	 => RA1,
			A2    	 => RA2,
			A3    	 => WA,
					
			WD3   	 => WD3,	
									
			R15   	 => PCPlus8,
					 
			RD1   	 => RD1,
			RD2   	 => RD2
		);
		
	Extend: SZEXTEND
		generic map(
			WIDTH_IN  => WIDTH_IN, 
			WIDTH_OUT => WIDTH
		)
		port map(
			SorZ   => ImmSrc,  
			SZ_in  => Instr,
			SZ_out => ExtImm
		);


end Behavioral;
