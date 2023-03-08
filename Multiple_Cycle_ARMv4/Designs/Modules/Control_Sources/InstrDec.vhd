library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity InstrDec is
	Port ( 
		op          :  in STD_LOGIC_VECTOR(1 downto 0);		-- Instr(27:26)
		funct       :  in STD_LOGIC_VECTOR(5 downto 0);		-- Instr(25:20)
		sh          :  in STD_LOGIC_VECTOR(1 downto 0);		-- Instr(6:5)
		
		RegSrc      : out STD_LOGIC_VECTOR(2 downto 0);
		ALUSrc      : out STD_LOGIC;
		MemtoReg    : out STD_LOGIC;
		ALUControl  : out STD_LOGIC_VECTOR(3 downto 0);
		ImmSrc      : out STD_LOGIC;
		
		NoWrite_in  : out STD_LOGIC);
end InstrDec;

architecture Behavioral of InstrDec is

begin

	process (op, funct, sh)
	
	begin
		
		RegSrc     <= "000";
		ALUSrc     <= '0';
		ImmSrc     <= '0';
		ALUControl <= "0000";
		MemtoReg   <= '0';
		NoWrite_in <= '0';
		
		case op is
			
			-- Data Processing
			when "00" =>
				
				case funct(4 downto 1) is
					
					-- ADD
					when "0100" => 
						RegSrc(1)  <= funct(5);	-- RegSrc[1] = I
						ALUSrc     <= funct(5);	-- ALUSrc = I
						ALUControl <= "0000";
					
					-- SUB
					when "0010" => 
						RegSrc(1)  <= funct(5);	
						ALUSrc     <= funct(5);	
						ALUControl <= "0001";
						
					-- CMP 
					when "1010" =>   
						
						if(funct(0) = '1') then
							RegSrc(1)  <= funct(5);	
							ALUSrc     <= funct(5);
							ALUControl <= "0001";
							NoWrite_in <= '1';
						else 
							null;
						end if;
					
					-- AND
					when "0000" =>
						RegSrc(1)  <= funct(5);	
						ALUSrc     <= funct(5);
						ALUControl <= "0010";
					
					-- ORR
					when "1100" =>
						RegSrc(1)  <= funct(5);	
						ALUSrc     <= funct(5);
						ALUControl <= "0011";
						
					-- MOV
					when "0110" =>
						RegSrc(1)  <= funct(5);	
						ALUSrc     <= funct(5);
						ALUControl <= "0100";
						
					-- MVN
					when "1111" =>
						RegSrc(1)  <= funct(5);	
						ALUSrc     <= funct(5);
						ALUControl <= "0101";
						
					-- EOR
					when "0001" =>
						RegSrc(1)  <= funct(5);	
						ALUSrc     <= funct(5);
						ALUControl <= "0111";
						
					-- SHIFT
					when "1101" =>
						if (funct(5) = '0') then
						
							-- LSL
							if (sh = "00") then
								ALUControl <= "1000";
							
							--LSR
							elsif (sh = "01") then
								ALUControl <= "1001";
								
							--ASR
							elsif (sh = "10") then
								ALUControl <= "1010";
								
							--ROR
							elsif (sh = "11") then
								ALUControl <= "1011";
							
							-- Null transition
							else
								null;
							end if;
						
						else
							null;
						end if;
					
					when others =>
						null;
						
				end case;
				
			-- Memory
			when "01" =>
				
				case funct is
					
					-- LDR U = 1
					when "011001" =>
						ALUSrc   <= '1';
						MemtoReg <= '1';
					
					-- LDR U = 0
					when "010001" =>
						ALUSrc     <= '1';
						ALUControl <= "0001";
						MemtoReg   <= '1';
						
					-- STR U = 1
					when "011000" =>
						ALUSrc <= '1';
						RegSrc <= "010";
					
					-- STR U = 0
					when "010000" =>
						ALUSrc     <= '1';
						RegSrc     <= "010";
						ALUControl <= "0001";
						
					when others =>
						null;
				
				end case;
				
			-- Branch
			when "10" =>
				
				-- B
				if (funct(5 downto 4) = "10") then
					RegSrc <= "001";	--2 downto 0 => 2,1,0
					ALUSrc <= '1';
					ImmSrc <= '1';
				
				-- BL
				elsif (funct(5 downto 4) = "11") then
					RegSrc <= "101";
					ALUSrc <= '1';
					ImmSrc <= '1';
				
				-- Null transition
				else
					null;
				end if;
				
			when others =>
				null;
		
		end case;	
	
	end process;


end Behavioral;