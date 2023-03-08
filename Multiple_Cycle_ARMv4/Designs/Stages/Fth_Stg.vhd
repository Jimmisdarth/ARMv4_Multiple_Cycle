library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Fth_Stg is
	Generic(WIDTH : positive := 32);
	Port (
		MemtoReg     :  in STD_LOGIC;
		PCSrc	     :  in STD_LOGIC_VECTOR(1 downto 0);
		
		ALUResult    :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		S_in		 :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		RD           :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		PCPlus4      :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		
		Result       : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
		PCN          : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end Fth_Stg;

architecture Behavioral of Fth_Stg is

	Component MUX2to1_n is
		generic (WIDTH : positive := 32); -- predifined value
		port (
			S  :  in STD_LOGIC;
			A0 :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			A1 :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
			Y  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0));
	end Component;
	
	Component MUX3_in_1 is
		generic (WIDTH : positive := 32);
		port ( 
			SEL :  in STD_LOGIC_VECTOR (1 downto 0);
			
			A   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			B   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			C   :  in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
			
			Y   : out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
	end Component;
	
	signal Internal_Result : STD_LOGIC_VECTOR (WIDTH-1 downto 0);

begin
	
	Mux_For_S_Or_RD: MUX2to1_n 
		generic map(
			WIDTH => WIDTH
		)
		port map(
			S  => MemtoReg,
			A0 => S_in,
			A1 => RD,
			Y  => Internal_Result
		);
	
	MUX_to_PC: MUX3_in_1
		generic map(
			WIDTH => WIDTH
		)
		port map( 
			SEL => PCSrc,
			
			A   => PCPlus4,
			B   => ALUResult,
			C   => Internal_Result,
			
			Y   => PCN
		);
		
	Result <= Internal_Result;

end Behavioral;
