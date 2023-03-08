library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FSM is
	Port ( 
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
end FSM;
	

architecture Behavioral of FSM is

	-- state definitions 
	type FSM_states is
	(S0, S1, S2a, S2b, S3, S4a, S4b, S4c, S4d, S4e, S4f, S4g, S4h, S4i);
	
	-- Binary kodikopoihsh
	attribute enum_encoding: string;
	attribute enum_encoding of FSM_states: type is "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101";
	
	-- internal singals
	signal current_state, next_state : FSM_states;
	
	-- gia to inreg
	signal op_inreg 	 : STD_LOGIC_VECTOR (1 downto 0);		  
	signal S_or_L_inreg  : STD_LOGIC;
	signal Rd_inreg   	 : STD_LOGIC_VECTOR (3 downto 0);
	signal Link_inreg	 : STD_LOGIC;
	
	signal NoWrite_inreg : STD_LOGIC;	
	signal CondEx_inreg  : STD_LOGIC;

begin

	-- Gia syncronazation
	INREG: process (CLK)
	begin
	
		if (CLK = '1' and CLK'event) then
			if (RESET = '1') then	
				op_inreg 	  <= "11";		--gia na pagideutei sth katastash S0
				S_or_L_inreg  <= '0';
				Rd_inreg   	  <= "0000";
				Link_inreg	  <= '0';
				NoWrite_inreg <= '0';
				CondEx_inreg  <= '0';	
			else
				op_inreg 	  <= op;	
				S_or_L_inreg  <= S_or_L;  
				Rd_inreg   	  <= Rd;     
				Link_inreg	  <= Link;	
				NoWrite_inreg <= NoWrite_in;
				CondEx_inreg  <= CondEx_in;
			end if;
		end if;
		
	end process;
	
	-- Process for FSM to create state register
	SYNC: process (CLK)
	
	begin
		
		if (CLK = '1' and CLK'event) then
			if (RESET = '1') then
				current_state <= S0;
			else
				current_state <= next_state;
			end if;
		end if;
		
	end process;
	
	--Process to create next state logic and output logic
	ASYNC: process (current_state, op_inreg, S_or_L_inreg, Rd_inreg, Link_inreg, NoWrite_inreg, CondEx_inreg)
	
	begin
		--FSM next state and output initialization
		next_state <= S0;
		
		IRWrite    <= '0';
		RegWrite   <= '0';
		MAWrite    <= '0';
		MemWrite   <= '0';
		FlagsWrite <= '0';
		PCSrc      <= "00";
		PCWrite    <= '0';
		
		case current_state is
			when S0  =>
				IRWrite <= '1';
				
				-- Trap S0
				if (op_inreg = "11") then
					next_state <= S0;
				else
					next_state <= S1;
				end if;
				
			when S1  =>
			
				-- cond not met
				if (CondEx_inreg = '0') then
					next_state <= S4c;
				else
					
					-- Branch
					if (op_inreg = "10") then
					
						-- BL
						if (Link_inreg = '1') then
							next_state <= S4i;	
						-- B
						else
							next_state <= S4h;
						end if;
					
					-- Memory
					elsif (op_inreg = "01") then
						next_state <= S2a;
					
					-- Data Processing
					elsif (op_inreg = "00") then
						
						-- CMP
						if (NoWrite_inreg = '1') then
							next_state <= S4g;
						else
							next_state <= S2b;
						end if;
					
					-- Akuro opcode
					else
						null;
					end if;
					
				end if;
			
			when S2a =>
				MAWrite <= '1';
				
				-- STR
				if (S_or_L_inreg = '0') then
					next_state <= S4d;
					
				-- LDR
				else
					next_state <= S3;
				end if;
			
			when S2b =>
				
				-- S = 0
				if (S_or_L_inreg = '0') then
					-- Rd = 15
					if (Rd_inreg = "1111") then
						next_state <= S4b;
					-- Rd /= 15
					else
						next_state <= S4a;
					end if;
				
				-- S = 1
				else
					-- Rd = 15
					if (Rd_inreg = "1111") then
						next_state <= S4f;
					-- Rd /= 15
					else
						next_state <= S4e;
					end if;
				
				end if;
				
			when S3  =>
			
				-- LDR, Rd = 15
				if (Rd_inreg = "1111") then
					next_state <= S4b;
					
				-- LDR, Rd /= 15
				else
					next_state <= S4a;
				end if;
			
			when S4a =>
			
				PCWrite  <= '1';
				RegWrite <= '1';
				
				next_state <= S0;
			
			when S4b =>
			
				PCSrc   <= "10";
				PCWrite <= '1';
				
				next_state <= S0;
			 
			when S4c =>
			
				PCWrite <= '1';
				
				next_state <= S0;
			
			when S4d =>
			
				PCWrite  <= '1';
				MemWrite <= '1';
				
				next_state <= S0;
			
			when S4e =>
			
				PCWrite    <= '1';
				RegWrite   <= '1';
				FlagsWrite <= '1';
				
				next_state <= S0;
			
			when S4f =>
				
				PCSrc      <= "10";
				PCWrite    <= '1';
				FlagsWrite <= '1';
				
				next_state <= S0;
			
			when S4g =>
			
				PCWrite    <= '1';
				FlagsWrite <= '1';
				
				next_state <= S0;
			
			when S4h =>
			
				PCSrc   <= "11";
				PCWrite <= '1';
				
				next_state <= S0;
			
			when S4i =>
			
				PCSrc    <= "11";
				PCWrite  <= '1';
				RegWrite <= '1';
				
				next_state <= S0;
						
			--fail-safe behavior
			when others =>
				next_state <= S0;
				
		end case;
		
	end process;

end Behavioral;
