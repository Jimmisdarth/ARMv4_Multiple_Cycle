library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;


entity FSM_tb is
--  Port ( );
end FSM_tb;

architecture Behavioral of FSM_tb is

	-- Unit Under Test (UUT)
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
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	signal RESET	 : STD_LOGIC := '1';
	
	signal op	      : STD_LOGIC_VECTOR(1 downto 0) := (others => 'X');
	signal Rd         : STD_LOGIC_VECTOR(3 downto 0) := (others => 'X');
    signal S_or_L     : STD_LOGIC := 'X';
	signal Link	      : STD_LOGIC := 'X';
	
	signal CondEx_in  : STD_LOGIC := 'X';	
	signal NoWrite_in : STD_LOGIC := 'X';
	
	-- External Outputs to UUT
	signal IRWrite    : STD_LOGIC;
	signal RegWrite   : STD_LOGIC;
	signal MAWrite    : STD_LOGIC;
	signal MemWrite   : STD_LOGIC;
	signal FlagsWrite : STD_LOGIC;
	signal PCSrc      : STD_LOGIC_VECTOR (1 downto 0);
	signal PCWrite    : STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	
	constant all_zeroes : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: FSM
			port map( 
				CLK        => CLK,
				RESET      => RESET,
				
				op		   => op,		   
				S_or_L     => S_or_L,    
				Rd         => Rd,        
				Link	   => Link,	  
		  
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
		
		variable CONCATENATE : STD_LOGIC_VECTOR (7 downto 0);
		
		begin
		
			--  Syncronous RESET is deasserted on CLK falling edge
			--  after GSR signal disable (it remains enabled for 100 ns)
			RESET <= '1';
			wait for 100 ns;
			wait until (CLK = '0' and CLK'event);
			RESET <= '0';
				
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			-- All paths from transition state diagram have to be activated
			-- After Reset deassert, Current State = S0
		
			op         <= "00";
			S_or_L     <= '0';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '0';
			
			------------------------------------
			--Current State = S0 Next State = S1	-- CondEx_in = 0
			------------------------------------
			wait for 2*clk_period;
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			

			-------------------------------------
			--Current State = S1 Next State = S4c
			-------------------------------------
			wait for clk_period;
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S4c PROBLEM" severity FAILURE;
			
			
			------------------------------------
			--Current State = S4c Next State = S0
			------------------------------------
			wait for clk_period;
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes(7 downto 1)&'1' report "S4c to S0 PROBLEM" severity FAILURE;
			
			
			------------------------------------
			--Current State = S0 Next State = S1	-- STR
			------------------------------------
			op         <= "01";		
			S_or_L     <= '0';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			wait for clk_period;
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2a
			-------------------------------------
			wait for clk_period;	-- 150ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2a PROBLEM" severity FAILURE;
			
			
			--------------------------------------
			--Current State = S2a Next State = S4d
			--------------------------------------
			wait for clk_period;	-- 160ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "001"&(all_zeroes(4 downto 0)) report "S2a to S4d PROBLEM" severity FAILURE;
			
			
			--------------------------------------
			--Current State = S4d Next State = S0
			--------------------------------------
			wait for clk_period;	-- 170ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00010001" report "S4d to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- LDR Rd /= 15
			-------------------------------------
			op         <= "01";		
			S_or_L     <= '1';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 180ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2a
			-------------------------------------
			wait for clk_period;	-- 190ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2a PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S2a Next State = S3
			-------------------------------------
			wait for clk_period;	-- 200ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00100000" report "S2a to S3 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S3 Next State = S4a
			-------------------------------------
			wait for clk_period;	-- 210ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S3 to S4a PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4a Next State = S0
			-------------------------------------
			wait for clk_period;	-- 220ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "01000001" report "S4a to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- LDR Rd = 15
			-------------------------------------
			op         <= "01";		
			S_or_L     <= '1';
			Rd         <= "1111";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 230ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2a
			-------------------------------------
			wait for clk_period;	-- 240ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2a PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S2a Next State = S3
			-------------------------------------
			wait for clk_period;	-- 250ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00100000" report "S2a to S3 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S3 Next State = S4b
			-------------------------------------
			wait for clk_period;	-- 260ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S3 to S4b PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4b Next State = S0	-- End of LDR Rd = 15
			-------------------------------------
			wait for clk_period;	-- 270ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00000101" report "S4b to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- CMP
			-------------------------------------
			op         <= "00";		
			S_or_L     <= '1';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '1';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 280ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S4g	
			-------------------------------------
			wait for clk_period;	-- 290ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S4g PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4g Next State = S0	-- End of CMP
			-------------------------------------
			wait for clk_period;	-- 300ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00001001" report "S4g to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- DP, S = 0, Rd /= 15
			-------------------------------------
			op         <= "00";		
			S_or_L     <= '0';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 310ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2b
			-------------------------------------
			wait for clk_period;	-- 320ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2b PROBLEM" severity FAILURE;
			
			
			--------------------------------------
			--Current State = S2b Next State = S4a
			--------------------------------------
			wait for clk_period;	-- 330ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S2b to S4a PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4a Next State = S0	-- End of DP, S = 0, Rd /= 15
			-------------------------------------
			wait for clk_period;	-- 340ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "01000001" report "S4a to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- DP, S = 0, Rd = 15
			-------------------------------------
			op         <= "00";		
			S_or_L     <= '0';
			Rd         <= "1111";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 350ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2b
			-------------------------------------
			wait for clk_period;	-- 360ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2b PROBLEM" severity FAILURE;
			
			
			--------------------------------------
			--Current State = S2b Next State = S4b
			--------------------------------------
			wait for clk_period;	-- 370ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S2b to S4b PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4b Next State = S0	End of DP, S = 0, Rd = 15
			-------------------------------------
			wait for clk_period;	-- 380ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00000101" report "S4b to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- DP, S = 1, Rd =/ 15
			-------------------------------------
			op         <= "00";		
			S_or_L     <= '1';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 390ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2b
			-------------------------------------
			wait for clk_period;	-- 400ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2b PROBLEM" severity FAILURE;
			
			
			--------------------------------------
			--Current State = S2b Next State = S4e
			--------------------------------------
			wait for clk_period;	-- 410ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S2b to S4e PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4e Next State = S0	End of DP, S = 1, Rd =/ 15
			-------------------------------------
			wait for clk_period;	-- 420ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "01001001" report "S4e to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- DP, S = 1, Rd = 15
			-------------------------------------
			op         <= "00";		
			S_or_L     <= '1';
			Rd         <= "1111";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 390ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S2b
			-------------------------------------
			wait for clk_period;	-- 400ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S2b PROBLEM" severity FAILURE;
			
			
			--------------------------------------
			--Current State = S2b Next State = S4f
			--------------------------------------
			wait for clk_period;	-- 410ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S2b to S4f PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4f Next State = S0	End of DP, S = 1, Rd = 15
			-------------------------------------
			wait for clk_period;	-- 420ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00001101" report "S4f to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- B
			-------------------------------------
			op         <= "10";		
			S_or_L     <= '0';
			Rd         <= "0000";
			Link       <= '0';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 430ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S4h
			-------------------------------------
			wait for clk_period;	-- 440ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S4h PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4h Next State = S0	-- End of B
			-------------------------------------
			wait for clk_period;	-- 450ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "00000111" report "S4h to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- BL
			-------------------------------------
			op         <= "10";		
			S_or_L     <= '0';
			Rd         <= "0000";
			Link       <= '1';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;	-- 460ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S1 Next State = S4i
			-------------------------------------
			wait for clk_period;	-- 470ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = all_zeroes report "S1 to S4i PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S4i Next State = S0	-- End of BL
			-------------------------------------
			wait for clk_period;	-- 480ns
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = "01000111" report "S4i to S0 PROBLEM" severity FAILURE;
			
			
			-------------------------------------
			--Current State = S0 Next State = S1	-- Akyro opcode
			-------------------------------------
			op         <= "11";		
			S_or_L     <= '0';
			Rd         <= "0100";
			Link       <= '1';
			NoWrite_in <= '0';
			CondEx_in  <= '1';
			
			wait for clk_period;
			
			CONCATENATE := IRWrite&RegWrite&MAWrite&MemWrite&FlagsWrite&PCSrc&PCWrite;
			assert CONCATENATE = '1'&(all_zeroes(6 downto 0)) report "S0 Trap PROBLEM" severity FAILURE;
			
			wait for 4*clk_period;
			
			                                      
			-- Message and stimulation end
			report "TEST COMPLETED";
			stop(2);
			
		end process;



end Behavioral;
