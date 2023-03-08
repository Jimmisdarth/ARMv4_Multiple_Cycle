library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity RegisterFile_Timed_tb is
--  Port ( );
end RegisterFile_Timed_tb;

architecture Behavioral of RegisterFile_Timed_tb is

	constant N : positive := 4;
	constant M : positive := 32;
	
	-- Unit Under Test (UUT)
	Component RegisterFile_Timed is
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
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	signal RESET     : STD_LOGIC := '1';
	
	signal RegWrite	 : STD_LOGIC := '0';
	
	signal A1   	 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');     
	signal A2   	 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');
	signal A3   	 : STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');

	signal WD3	     : STD_LOGIC_VECTOR(M-1 downto 0) := (others => 'X');
	
	signal R15		 : STD_LOGIC_VECTOR(M-1 downto 0) := (others => 'X');

	-- External Outputs to UUT
	signal RD1 		 : STD_LOGIC_VECTOR(M-1 downto 0);
	signal RD2 	     : STD_LOGIC_VECTOR(M-1 downto 0);
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	
begin

	-- Instantiate the Unit Under Test (UUT)
		uut: RegisterFile_Timed
			port map(
				CLK      => CLK,
				RESET    => RESET,
				RegWrite => RegWrite,
						 
				A1   	 => A1,     
				A2   	 => A2,  
				A3   	 => A3,  
								 
				WD3  	 => WD3, 
								 
				R15  	 => R15, 
								 
				RD1  	 => RD1, 
				RD2  	 => RD2
			);
			
		-- H diadiakasia gia na dhmiourgisoume to roloi
		CLK_process : process
			begin
				CLK <= '0';
				wait for clk_period/2;
				CLK <= '1';
				wait for clk_period/2;
			end process;
			
	-- Stimulus process definition
		Stimulus_process: process
		
			begin
			--  Syncronous RESET is deasserted on CLK falling edge
			--  after GSR signal disable (it remains enabled for 100 ns)
				RESET    <= '1';
				RegWrite <= '0';
				wait for 100 ns;
				wait until (CLK = '0' and CLK'event);
				RESET       <= '0';
				RegWrite    <= '1';
				A1  <= x"0";
				A2  <= x"0";
				R15 <= x"0000A100";
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
				
			-- Egrafoume se olous tous kataxwrhtes times plin tou R15 meta apo to for
			-- Tha isxuei Ri = i, tha egrajoume kai th timh me dieuthinsh 15 alla the
			-- Tha perimenoume na doume kapoia allagh ston kataxwrhth R15
				for I in 0 to 2**N-1 loop
					A3  <= std_logic_vector(to_unsigned(I, A1'length));
					WD3 <= std_logic_vector(to_unsigned(I, WD3'length));		
					wait for clk_period;
				end loop;
				
			-- Mhdenizoume to RegWrite
				RegWrite <= '0';
				A3   	 <= x"0";
				WD3  	 <= x"0000_0000";
				wait for clk_period;
				
			-- Diabouzoume dyo kataxwrthtes tautoxrona gia na doyme oti egine h swsth
			-- Egrafh kai tsekaroume kai ton R14
				for I in 0 to 2**(N-1)-2 loop
					A1 <= std_logic_vector(to_unsigned(2*I, A1'length));
					A2 <= std_logic_vector(to_unsigned(2*I+1, A2'length));
					wait for 3*clk_period;
					
					assert RD1=std_logic_vector(to_unsigned(2*I, RD1'length)) report "PROBLEM AT ADDRESS PORT" severity FAILURE; 
					assert RD2=std_logic_vector(to_unsigned(2*I+1, RD2'length)) report "PROBLEM AT ADDRESS PORT" severity FAILURE;
				end loop;
				
				A1 <= x"E";
				A2 <= x"F";
				wait for 3*clk_period;
				
				assert RD1=std_logic_vector(to_unsigned(14, RD1'length)) report "PROBLEM AT ADDRESS PORT" severity FAILURE; 
				assert RD2=R15 report "PROBLEM AT ADDRESS PORT" severity FAILURE;
				
				wait for clk_period;
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;


end Behavioral;
