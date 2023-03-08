library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity Control_tb is
--  Port ( );
end Control_tb;

architecture Behavioral of Control_tb is

	-- Unit Under Test (UUT)
	Component Control is
		port ( 
			Instruction :  in STD_LOGIC_VECTOR(31 downto 20);
			Rd			:  in STD_LOGIC_VECTOR(3 downto 0);
			Flags       :  in STD_LOGIC_VECTOR(3 downto 0);
						
			RegSrc      : out STD_LOGIC_VECTOR(2 downto 0);
			RegWrite    : out STD_LOGIC;
			ImmSrc      : out STD_LOGIC;
						
			ALUSrc      : out STD_LOGIC;
			ALUControl  : out STD_LOGIC_VECTOR(1 downto 0);
			FlagsWrite  : out STD_LOGIC;
						
			MemWrite    : out STD_LOGIC;
						
			MemtoReg    : out STD_LOGIC;
			PCSrc	    : out STD_LOGIC);
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	
	signal Instruction : STD_LOGIC_VECTOR(31 downto 20) := (others => 'X');
	signal Rd	 	   : STD_LOGIC_VECTOR(3 downto 0)   := (others => 'X');
	signal Flags 	   : STD_LOGIC_VECTOR(3 downto 0)   := (others => 'X');

	-- External Outputs to UUT
	signal RegSrc     : STD_LOGIC_VECTOR(2 downto 0);
	signal RegWrite   : STD_LOGIC;
	signal ImmSrc     : STD_LOGIC;
 			
	signal ALUSrc     : STD_LOGIC;
	signal ALUControl : STD_LOGIC_VECTOR(1 downto 0);
	signal FlagsWrite : STD_LOGIC;
 			
	signal MemWrite   : STD_LOGIC;
			
	signal MemtoReg   : STD_LOGIC;
	signal PCSrc	  : STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	
	type cmd_array is array (0 to 4) of std_logic_vector(3 downto 0);
	constant cmd : cmd_array := (
			"0100",	-- ADD
			"0010",	-- SUB
			"0000",	-- AND
			"1100",	-- ORR
			"1010" 	-- CMP
		);
		
	type dp_response_array is array (0 to 4) of std_logic_vector(3 downto 0);
	constant dp_response : dp_response_array := (
			"0000",	-- ADD
			"0010",	-- SUB
			"0100",	-- AND	 -- ImmSrc & ALUControl & MemtoReg
			"0110", -- ORR
			"0010" 	-- CMP
		);
		
	type IPUBWL_array is array (0 to 3) of std_logic_vector(5 downto 0);
	constant IPUBWL : IPUBWL_array := (
			"011001",	-- LDR +
			"010001",	-- LDR -
			"011000",	-- STR +
			"010000"	-- STR -
		);
		
	type memory_response_array is array (0 to 3) of std_logic_vector(7 downto 0);
	constant mem_response : memory_response_array := (
			"00010001",	-- LDR +
			"00010011",	-- LDR -
			"01010000",	-- STR +
			"01010010"	-- STR -
		);
		
	constant branch_response : STD_LOGIC_VECTOR(7 downto 0) := "00111000";
	constant all_zeroes      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: Control
			port map( 
				Instruction => Instruction,
				Rd			=> Rd,			
				Flags       => Flags,      
                               
				RegSrc      => RegSrc,     
				RegWrite    => RegWrite,   
				ImmSrc      => ImmSrc,     
                               
				ALUSrc      => ALUSrc,     
				ALUControl  => ALUControl, 
				FlagsWrite  => FlagsWrite, 
                               
				MemWrite    => MemWrite,   
                               
				MemtoReg    => MemtoReg,   
				PCSrc	    => PCSrc	   
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
			
			variable CONCATENATE_IN  : STD_LOGIC_VECTOR(19 downto 0);
			
			variable cond  : STD_LOGIC_VECTOR(3 downto 0);
			
			variable op	   : STD_LOGIC_VECTOR(1 downto 0);
			variable funct : STD_LOGIC_VECTOR(5 downto 0);
			
			variable N, Z, C, V : STD_LOGIC;
			
			variable condition_is_ok : STD_LOGIC;
			
			variable found : integer := 0;
			variable CONCATENATE : STD_LOGIC_VECTOR(7 downto 0);
		
			begin
				
				Instruction  <= (others => '0');
				Rd   	     <= (others => '0');
			    Flags        <= (others => '0');
				wait for 10 ns;
				wait until (CLK = '0' and CLK'event);
				
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			
			------------------------------------------------
			--To sim tha trejei gia 1,048,576+1 kykloys rologiou--
			------------------------------------------------
				
				for I in 0 to 2**12-1 loop
					Instruction <= std_logic_vector(to_unsigned(I, Instruction'length));
					
					for J in 0 to 2**4-1 loop
						Rd <= std_logic_vector(to_unsigned(J, Rd'length));
						
						for K in 0 to 2**4-1 loop
							Flags <= std_logic_vector(to_unsigned(K, Flags'length));
							wait for clk_period;
							
							cond  := Instruction(31 downto 28);
							
							op    := Instruction(27 downto 26);
							funct := Instruction(25 downto 20);
							
							N := Flags(3);
							Z := Flags(2);
							C := Flags(1);
							V := Flags(0);
							
							-----------------------------------------
							--Elegxoume an ikanoipoieitai h synthkh--
							--ekteleshs ths entolhs------------------
							-----------------------------------------
							if    (cond = "0000" and Z = '1') then
								condition_is_ok := '1';
						
							elsif (cond = "0001" and Z = '0') then 
								condition_is_ok := '1';
								
							elsif (cond = "0010" and C = '1') then
								condition_is_ok := '1';
							
							elsif (cond = "0011" and C = '0') then
								condition_is_ok := '1';
								
							elsif (cond = "0100" and N = '1') then
								condition_is_ok := '1';
								
							elsif (cond = "0101" and N = '0') then
								condition_is_ok := '1';
							
							elsif (cond = "0110" and V = '1') then
								condition_is_ok := '1';
								
							elsif (cond = "0111" and V = '0') then
								condition_is_ok := '1';
							
							elsif (cond = "1000" and Z = '0' and C = '1') then
								condition_is_ok := '1';
								
							elsif (cond = "1001" and (Z = '1' or C = '0')) then
								condition_is_ok := '1';
								
							elsif (cond = "1010" and (N xor V) = '0') then
								condition_is_ok := '1';
								
							elsif (cond = "1011" and (N xor V) = '1') then
								condition_is_ok := '1';
								
							elsif (cond = "1100" and (Z = '0' and (N xor V) = '0')) then
								condition_is_ok := '1';
							
							elsif (cond = "1101" and (Z = '1' or (N xor V) = '1')) then
								condition_is_ok := '1';
								
							elsif (cond = "1110") then
								condition_is_ok := '1';
							
							elsif (cond = "1111") then
								condition_is_ok := '1';
							
							else
								condition_is_ok := '0';
							end if;	
							
							--------------------------------------------------
							--Ean den ikanopoieitai h synthkh tha prepei ta--- 
							--shmata egrafhs kai to PCSrc na einai ola mhden--
							--------------------------------------------------
							if (condition_is_ok = '0') then
								assert MemWrite   = '0' report "MemWrite Problem"   severity FAILURE;
								assert FlagsWrite = '0' report "FlagsWrite Problem" severity FAILURE;
								assert RegWrite   = '0' report "RegWrite Problem"   severity FAILURE;
								assert PCSrc      = '0' report "PCSrc Problem"      severity FAILURE;
							else
							
								found := 0;
								
								---------------------
								-- Data Processing --
								---------------------
								if (op = "00") then
					
									-- Ean pesoume sthn entolh CMP
									if (funct(4 downto 1) = cmd(4)) then
										if (funct(0) = '1') then
											CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
											assert CONCATENATE = '0'&funct(5)&'0'&funct(5)&dp_response(4)
												report "CMP PROBLEM" severity FAILURE;
											
											assert RegWrite   = '0' report "CMP RegWrite PROBLEM"   severity FAILURE;
											assert MemWrite   = '0' report "CMP MemWrite PROBLEM"   severity FAILURE;
											assert FlagsWrite = '1' report "CMP FlagsWrite PROBLEM" severity FAILURE;
												
											found := 1;
										end if;
									else
										--Periptwseis gia tis alles entoles
										for J in 0 to 3 loop
											if (funct(4 downto 1)  = cmd(J)) then 
												CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
												assert CONCATENATE = '0'&funct(5)&'0'&funct(5)&dp_response(J)
													report "cmd PROBLEM" severity FAILURE;
													
												-- Check WELogic
												if (Instruction(20) = '0') then
													assert RegWrite   = '1' report "DP RegWrite PROBLEM"   severity FAILURE;
													assert MemWrite   = '0' report "DP MemWrite PROBLEM"   severity FAILURE;
													assert FlagsWrite = '0' report "DP FlagsWrite PROBLEM" severity FAILURE;
												else
													assert RegWrite   = '1' report "DP RegWrite PROBLEM"   severity FAILURE;
													assert MemWrite   = '0' report "DP MemWrite PROBLEM"   severity FAILURE;
													assert FlagsWrite = '1' report "DP FlagsWrite PROBLEM" severity FAILURE;
												end if;
												
												-- Check PCSrc
												if (Rd = "1111") then
													assert PCSrc = '1' report "DP PCSrc Problem" severity FAILURE;
												else
													assert PCSrc = '0' report "DP PCSrc Zero Problem" severity FAILURE;
												end if;
													
												found := 1;
											end if;
										end loop;
									end if;
									
									if (found = 0) then
										CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
										assert CONCATENATE = all_zeroes 
											report "DP Zero PROBLEM" severity FAILURE;	
									end if;								
								
								---------------------
								------ Memory -------
								---------------------
								elsif (op = "01") then
								
									for J in 0 to 3 loop
										if (funct = IPUBWL(J)) then 
											CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
											assert CONCATENATE = mem_response(J) 
												report "Memory PROBLEM" severity FAILURE;
												
											-- Check WELogic
											if (Instruction(20) = '1') then
												assert RegWrite   = '1' report "Me RegWrite PROBLEM"   severity FAILURE;
												assert MemWrite   = '0' report "Me MemWrite PROBLEM"   severity FAILURE;
												assert FlagsWrite = '0' report "Me FlagsWrite PROBLEM" severity FAILURE;
											else
												assert RegWrite   = '0' report "Me Zero RegWrite PROBLEM"   severity FAILURE;
												assert MemWrite   = '1' report "Me Zero MemWrite PROBLEM"   severity FAILURE;
												assert FlagsWrite = '0' report "Me Zero FlagsWrite PROBLEM" severity FAILURE;
											end if;	

											-- Check PCSrc
											if (Rd = "1111" and (funct = IPUBWL(0) or funct = IPUBWL(1))) then
												assert PCSrc = '1' report "Me PCSrc Problem" severity FAILURE;
											else
												assert PCSrc = '0' report "Me PCSrc Zero Problem" severity FAILURE;
											end if;
												
											found := 1;
										end if;
										end loop;
										
										if (found = 0) then
											CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
											assert CONCATENATE = all_zeroes 
												report "Memory Zero PROBLEM" severity FAILURE;			
										end if;
								
								
								---------------------
								------ Branch -------
								---------------------
								elsif (op = "10") then
								
									-- Ean pesoume panw sthn entolh Branch
									if (funct(5 downto 4) = "10") then
										CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
										assert CONCATENATE = branch_response 
											report "Branch_1 PROBLEM" severity FAILURE;						
									else	
										CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
										assert CONCATENATE = all_zeroes 
											report "Branch_2 PROBLEM" severity FAILURE;
									end if;
									
									-- Check WELogic
									assert RegWrite   = '0' report "Bracnh RegWrite PROBLEM"   severity FAILURE;
									assert MemWrite   = '0' report "Bracnh MemWrite PROBLEM"   severity FAILURE;
									assert FlagsWrite = '0' report "Bracnh FlagsWrite PROBLEM" severity FAILURE;
									
									assert PCSrc = '1' report "Branch PCSrc PROBLEM" severity FAILURE;
									
									
								----------------------
								---- Akyro opcode ----
								----------------------
								else
								
									CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg;
									assert CONCATENATE = all_zeroes 
											report "Not Valid Command PROBLEM" severity FAILURE;
											
									-- Check WELogic
									assert RegWrite   = '0' report "OPCODE RegWrite PROBLEM"   severity FAILURE;
									assert MemWrite   = '0' report "OPCODE MemWrite PROBLEM"   severity FAILURE;
									assert FlagsWrite = '0' report "OPCODE FlagsWrite PROBLEM" severity FAILURE;
									
									assert PCSrc = '0' report "OPCODE PCSrc PROBLEM" severity FAILURE;
								
								end if;								
							end if;

						end loop;	-- Flags
					end loop;	-- Rd
				end loop;	-- Instruction
			
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;


end Behavioral;
