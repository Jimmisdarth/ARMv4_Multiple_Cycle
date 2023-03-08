library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity REGFILE_tb is
--  Port ( );
end REGFILE_tb;

architecture Behavioral of REGFILE_tb is

	constant N : positive := 4;
	constant M : positive := 32;
	
	-- Unit Under Test (UUT)
	Component REGFILE is
		generic (
			N : positive := 4;		--address length
			M : positive := 32);	--data word length
		port (
			CLK       :  in STD_LOGIC;
			
			WE	      :  in STD_LOGIC;
			ADDR_W    :  in STD_LOGIC_VECTOR (N-1 downto 0);
			
			ADDR_R1   :  in STD_LOGIC_VECTOR (N-1 downto 0);
			ADDR_R2   :  in STD_LOGIC_VECTOR (N-1 downto 0);
			
			DATA_IN   :  in STD_LOGIC_VECTOR (M-1 downto 0);
			
			DATA_OUT1 : out STD_LOGIC_VECTOR (M-1 downto 0);
			DATA_OUT2 : out STD_LOGIC_VECTOR (M-1 downto 0));
	end Component;
	
	-- Internal Inputs to UUT
	signal CLK 	  	 : STD_LOGIC := '0';
	signal WE	     : STD_LOGIC := '0';
	
	signal ADDR_W    : STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');

	signal ADDR_R1   : STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');
	signal ADDR_R2   : STD_LOGIC_VECTOR(N-1 downto 0) := (others => 'X');

	signal DATA_IN   : STD_LOGIC_VECTOR(M-1 downto 0) := (others => 'X');

	-- External Outputs to UUT
	signal DATA_OUT1 : STD_LOGIC_VECTOR(M-1 downto 0);
	signal DATA_OUT2 : STD_LOGIC_VECTOR(M-1 downto 0);
	
	-- Clock period definitions
	constant CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
		uut: REGFILE
			generic map(
				N => N,	--address length
				M => M	--data word length
			)
			port map(
				CLK       => CLK,
						 
				WE	      => WE,     
				ADDR_W    => ADDR_W,  
						     		 
				ADDR_R1   => ADDR_R1,  
				ADDR_R2   => ADDR_R2,  
						     		 
				DATA_IN   => DATA_IN, 
						     		 
				DATA_OUT1 => DATA_OUT1,
				DATA_OUT2 => DATA_OUT2
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
				WE <= '0';
				wait for 100 ns;
				wait until (CLK = '0' and CLK'event);
				WE    <= '1';
				ADDR_R1 <= x"0";
				ADDR_R2 <= x"0";	
		
			-- UUT inputs are asserted and deasserted on CLK falling edge
			-- All paths from transition state diagram have to be activated
			-- After Reset deassert, D = X0
				
				for I in 0 to 2**N-2 loop
					ADDR_W  <= std_logic_vector(to_unsigned(I, ADDR_W'length));
					DATA_IN <= std_logic_vector(to_unsigned(I, DATA_IN'length));		
					wait for clk_period;
				end loop;
				
				WE      <= '0';
				ADDR_W  <= x"0";
				DATA_IN <= x"0000_0000";
				wait for clk_period;
				
				for I in 0 to 2**(N-1)-2 loop
					ADDR_R1 <= std_logic_vector(to_unsigned(2*I, ADDR_R1'length));
					ADDR_R2 <= std_logic_vector(to_unsigned(2*I+1, ADDR_R2'length));
					wait for clk_period;
					
					assert DATA_OUT1=std_logic_vector(to_unsigned(2*I, DATA_OUT1'length)) report "PROBLEM AT ADDRESS PORT" severity FAILURE; 
					assert DATA_OUT2=std_logic_vector(to_unsigned(2*I+1, DATA_OUT2'length)) report "PROBLEM AT ADDRESS PORT" severity FAILURE;
				end loop;
				
				ADDR_R1 <= x"E";
				wait for clk_period;
				
				ADDR_R2 <= x"F";
				wait for clk_period;
				
			-- Message and stimulation end
				report "TEST COMPLETED";
				stop(2);
				
			end process;

end Behavioral;
