library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;


entity InstrDec_tb is
--  Port ( );
end InstrDec_tb;

architecture Behavioral of InstrDec_tb is
	
	-- Unit Under Test (UUT)
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
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	
	signal op    : STD_LOGIC_VECTOR(1 downto 0) := (others => 'X');
	signal funct : STD_LOGIC_VECTOR(5 downto 0) := (others => 'X');
	signal sh 	 : STD_LOGIC_VECTOR(1 downto 0) := (others => 'X');

	-- External Outputs to UUT
	signal RegSrc     : STD_LOGIC_VECTOR(2 downto 0);
	signal ALUSrc     : STD_LOGIC;
	signal MemtoReg   : STD_LOGIC;
	signal ALUControl : STD_LOGIC_VECTOR(3 downto 0);
	signal ImmSrc     : STD_LOGIC;
	signal NoWrite_in : STD_LOGIC;
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;
	
	
	type cmd_array is array (0 to 7) of std_logic_vector(3 downto 0);
	constant cmd : cmd_array := (
			"1010",	-- CMP
			"0100",	-- ADD
			"0010",	-- SUB
			"0000",	-- AND
			"1100",	-- ORR
			
			"0110", -- MOV
			"1111", -- MVN
			"0001"  -- EOR
		);
	
	constant shift_cmd : STD_LOGIC_VECTOR (4 downto 0) := "01101";
	
	type shift_array is array (0 to 3) of std_logic_vector(1 downto 0);
	constant shift : shift_array := (
			"00", -- LSL
			"01", -- LSR
			"10", -- ASR
			"11"  -- ROR
		);
		
	type dp_response_array is array (0 to 7) of std_logic_vector(6 downto 0);
	constant dp_response : dp_response_array := (
			"0000101", 	-- CMP
			"0000000",	-- ADD
			"0000100",	-- SUB
			"0001000",	-- AND	 	-- ImmSrc & ALUControl & MemtoReg & NoWrite_in
			"0001100", 	-- ORR
			
			"0010000",  -- MOV
			"0010100",  -- MVN
			"0011100"   -- EOR
		);
		
	type shift_response_array is array (0 to 3) of std_logic_vector(6 downto 0);
	constant shift_response : shift_response_array := (   
			"0100000",  -- LSL
			"0100100",  -- LSR		-- ImmSrc & ALUControl & MemtoReg & NoWrite_in
			"0101000",  -- ASR
			"0101100"   -- ROR
		);
		
	type IPUBWL_array is array (0 to 3) of std_logic_vector(5 downto 0);
	constant IPUBWL : IPUBWL_array := (
			"011001",	-- LDR +
			"010001",	-- LDR -
			"011000",	-- STR +
			"010000"	-- STR -
		);
		
	type memory_response_array is array (0 to 3) of std_logic_vector(10 downto 0);
	constant mem_response : memory_response_array := (
			"00010000010",	-- LDR +
			"00010000110",	-- LDR -	-- RegSrc & ALUSrc & ImmSrc & ALUControl & MemtoReg & NoWrite_in
			"01010000000",	-- STR +
			"01010000100"	-- STR -
		);
		
	constant B_response  : STD_LOGIC_VECTOR (10 downto 0) := "00111000000";
	constant BL_response : STD_LOGIC_VECTOR (10 downto 0) := "10111000000";
	constant all_zeroes  : STD_LOGIC_VECTOR (10 downto 0) := (others => '0');
		

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: InstrDec
			port map( 
				op          => op,        
				funct       => funct, 
				sh			=> sh,
                               
				RegSrc      => RegSrc,    
				ALUSrc      => ALUSrc,    
				MemtoReg    => MemtoReg,  
				ALUControl  => ALUControl,
				ImmSrc      => ImmSrc,  
                               
				NoWrite_in  => NoWrite_in
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
			
		variable found : integer := 0;
		variable CONCATENATE : STD_LOGIC_VECTOR(10 downto 0);
		
		begin
			op    <= (others => '0');
			funct <= (others => '0');
			sh    <= (others => '0');
			wait for 10 ns;
			wait until (CLK = '0' and CLK'event);
			
		
		-- UUT inputs are asserted and deasserted on CLK falling edge
		
		------------------------------------------------
		--To sim tha trejei gia 1024+1 kykloys rologiou--
		------------------------------------------------
			
			---------------------
			-- Data Processing --
			---------------------
			
			op <= "00";
			for I in 0 to 63 loop
				funct <= std_logic_vector(to_unsigned(I, funct'length));
				
				for K in 0 to 3 loop
					sh <= std_logic_vector(to_unsigned(K, sh'length));
					
					wait for clk_period;
				
					found := 0;
					
					-- Ean pesoume sthn entolh CMP
					if (funct(4 downto 1) = cmd(0)) then
						if (funct(0) = '1') then
							CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
							assert CONCATENATE = '0'&funct(5)&'0'&funct(5)&dp_response(0)
								report "CMP PROBLEM" severity FAILURE;
								
							found := 1;
						end if;
					
					-- Ean pesoume se entolh me shift "01101"
					elsif (funct(5 downto 1) = shift_cmd) then
						for J in 0 to 3 loop
							if (sh = shift(J)) then
								CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
								assert CONCATENATE = '0'&funct(5)&'0'&funct(5)&shift_response(J)
									report "SHIFT PROBLEM" severity FAILURE;
									
								found := 1;
							end if;
						end loop;
			
					else
						-- Periptwseis gia tis entoles
						for J in 1 to 7 loop
							if (funct(4 downto 1) = cmd(J)) then 
								CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
								assert CONCATENATE = '0'&funct(5)&'0'&funct(5)&dp_response(J)
									report "cmd PROBLEM" severity FAILURE;
									
								found := 1;
							end if;
						end loop;
					end if;
					
					if (found = 0) then
						CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
						assert CONCATENATE = all_zeroes 
							report "DP Zero PROBLEM" severity FAILURE;			
					end if;						
				end loop;			
			end loop;
			
		
		---------------------
		------ Memory -------
		---------------------
		
		op <= "01";
		for K in 0 to 3 loop
			sh <= std_logic_vector(to_unsigned(K, sh'length));
			
			for I in 0 to 63 loop
				funct <= std_logic_vector(to_unsigned(I, funct'length));
				wait for clk_period;
				
				found := 0;
				
				for J in 0 to 3 loop
					if (funct = IPUBWL(J)) then 
						CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
						assert CONCATENATE = mem_response(J) 
							report "Memory PROBLEM" severity FAILURE;
							
						found := 1;
					end if;
				end loop;
				
				if (found = 0) then
					CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
					assert CONCATENATE = all_zeroes 
						report "Memory Zero PROBLEM" severity FAILURE;			
				end if;
			end loop;	
		end loop;
		
		
		---------------------
		------ Branch -------
		---------------------
		
		op <= "10";
		for K in 0 to 3 loop
			sh <= std_logic_vector(to_unsigned(K, sh'length));
			
			for I in 0 to 63 loop
				funct <= std_logic_vector(to_unsigned(I, funct'length));
				wait for clk_period;
				
				-- Ean pesoume panw sthn entolh Branch
				if (funct(5 downto 4) = "10") then
					CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
					assert CONCATENATE = B_response 
						report "B PROBLEM" severity FAILURE;
					
				-- Ean pesoume panw se entolh Branch and Link
				elsif (funct(5 downto 4) = "11") then
					CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
					assert CONCATENATE = BL_response 
						report "BL PROBLEM" severity FAILURE;
				
				else	
					CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
					assert CONCATENATE = all_zeroes 
						report "Branch_2 PROBLEM" severity FAILURE;
				end if;	
			end loop;
		end loop;
		
		
		----------------------
		---- Akyro opcode ----
		----------------------
		
		op <= "11";
		for I in 0 to 63 loop
			funct <= std_logic_vector(to_unsigned(I, funct'length));
			for K in 0 to 3 loop
				sh <= std_logic_vector(to_unsigned(K, sh'length));
				wait for clk_period;
			
				CONCATENATE := RegSrc&ALUSrc&ImmSrc&ALUControl&MemtoReg&NoWrite_in;
				assert CONCATENATE = all_zeroes 
						report "Not Valid Command PROBLEM" severity FAILURE;		
			end loop;
		end loop;
		
			
		-- Message and stimulation end
			report "TEST COMPLETED";
			stop(2);
			
		end process;


end Behavioral;
