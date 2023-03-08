library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity ALU_tb is
--  Port ( );
end ALU_tb;

architecture Behavioral of ALU_tb is

	constant WIDTH : positive := 32;

	Component ALU is
	Port (
		ALUControl :  in STD_LOGIC_VECTOR (3 downto 0);
		shamt5	   :  in STD_LOGIC_VECTOR (4 downto 0);
		
		A 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		B 		   :  in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		
		ALUResult  : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
		Flags      : out STD_LOGIC_VECTOR (3 downto 0));	
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK : STD_LOGIC := '0';
	
	signal A : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => 'X');
	signal B : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => 'X');
	
	signal ALUControl : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
	signal shamt5	  : STD_LOGIC_VECTOR (4 downto 0) := (others => 'X');
	
	-- Internal Output from UUT
	signal ALUResult : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
	signal Flags     : STD_LOGIC_VECTOR (3 downto 0);
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: ALU
		port map( 
			ALUControl => ALUControl,
			shamt5     => shamt5,
			
            A 		   => A,
            B 		   => B,

            ALUResult  => ALUResult,
            Flags      => Flags
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
		
		variable shamt_n : NATURAL range 0 to 31;
		
		variable B_s :   SIGNED (WIDTH-1 downto 0);
		variable B_u : UNSIGNED (WIDTH-1 downto 0);
		
		begin
		--  Syncronous RESET is deasserted on CLK falling edge
		--  after GSR signal disable (it remains enabled for 100 ns)
			ALUControl <= "0000";
			wait for 10 ns;
			wait until (CLK = '0' and CLK'event);
			
		
		-- UUT inputs are asserted and deasserted on CLK falling edge
			
			------------------------
			--Periptwsh prostheshs--
			------------------------
			
			ALUControl <= "0000";
			shamt5     <= "00000";
			wait for clk_period;
			
			A <= x"FFFF_FFFF";	-- -1
			B <= x"8000_0000";	-- -2**31
			wait for clk_period;
			
			A <= x"0000_0001";	-- +1
			B <= x"8000_0000";	-- -2**31
			wait for clk_period;
			
			A <= x"0000_0001";	-- +1
			B <= x"7FFF_FFFF";	-- +2**31-1
			wait for clk_period;
			
			A <= x"FFFF_FFFF";	-- -1
			B <= x"7FFF_FFFF";	-- +2**31-1
			wait for clk_period;
			
			A <= x"0000_C350";	-- +50.000
			B <= x"0001_86A0";	-- -100.000
			wait for clk_period;
			
			-----------------------
			--Periptwsh afaireshs--
			-----------------------
			
			ALUControl <= "0001";
			shamt5     <= "00000";
			wait for clk_period;
			
			A <= x"8000_0000";	-- -2**31
			B <= x"FFFF_FFFF";	-- -1
			wait for clk_period;
			
			A <= x"8000_0000";	-- -2**31
			B <= x"0000_0001";	-- +1
			wait for clk_period;
			
			A <= x"0000_0001";	-- +1
			B <= x"7FFF_FFFF";	-- +2**31-1
			wait for clk_period;
			
			A <= x"FFFF_FFFF";	-- -1
			B <= x"7FFF_FFFF";	-- +2**31-1
			wait for clk_period;
			
			A <= x"0000_C350";	-- +50.000
			B <= x"0001_86A0";	-- -100.000
			wait for clk_period;
			
			-------------------------
			--Ypoloipes Periptwseis--
			-------------------------
			
			shamt5 <= "00001";
			
			for I in 2 to 15 loop
				ALUControl <= std_logic_vector(to_unsigned(I, ALUControl'length));
				
				for J in -40 to 40 loop
					for K in -40 to 40 loop
						A <= std_logic_vector(to_signed(J, A'length));
						B <= std_logic_vector(to_signed(K, B'length));
						wait for clk_period;
						
						-- Elegxos gia to mask twn flags
						if (ALUControl(1) = '1') then
							assert Flags(1 downto 0) = "00" report "Flag Mask PROBLEM" 
								severity FAILURE;
						end if;
						
						shamt_n := to_integer(unsigned(shamt5));
						
						B_s := signed(B);
						B_u := unsigned(B);
						
						if    (ALUControl = "0010") then
							assert (A and B) = ALUResult report "AND PROBLEM" severity FAILURE;
							
						elsif (ALUControl = "0011") then
							assert (A or B) = ALUResult report "OR PROBLEM" severity FAILURE;
							
						elsif (ALUControl = "0100") then
							assert B = ALUResult report "MOV PROBLEM" severity FAILURE;
						
						elsif (ALUControl = "0101") then
							assert (not B) = ALUResult report "MVN PROBLEM" severity FAILURE;
							
						elsif (ALUControl = "0110" or ALUControl = "0111") then
							assert (A xor B) = ALUResult report "XOR PROBLEM" severity FAILURE;
							
						elsif (ALUControl = "1000" or ALUControl = "1100") then	
							assert std_logic_vector(SHIFT_LEFT (B_u, shamt_n)) = ALUResult 
								report "LSL PROBLEM" severity FAILURE;
								
						elsif (ALUControl = "1001" or ALUControl = "1101") then	
							assert std_logic_vector(SHIFT_RIGHT (B_u, shamt_n)) = ALUResult 
								report "LSR PROBLEM" severity FAILURE;
								
						elsif (ALUControl = "1010" or ALUControl = "1110") then	
							assert std_logic_vector(SHIFT_RIGHT (B_s, shamt_n)) = ALUResult 
								report "ASR PROBLEM" severity FAILURE;
								
						elsif (ALUControl = "1011" or ALUControl = "1111") then	
							assert std_logic_vector(ROTATE_RIGHT (B_s, shamt_n)) = ALUResult 
								report "ROR PROBLEM" severity FAILURE;
								
						end if;
						
					end loop;
				end loop;	
			end loop;
		
			
			
		-- Message and stimulation end
			report "TEST COMPLETED";
			stop(2);
			
		end process;
	


end Behavioral;
