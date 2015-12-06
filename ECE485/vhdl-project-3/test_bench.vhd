library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_bench is
end test_bench;

architecture behavioral of test_bench is
	signal clk : std_logic;
	signal extPC, IMdata, DMdata,DMaddr : std_logic_vector(31 downto 0) := x"00000000";

	signal IMwrite, DMwrite, stall : std_logic := '0';
begin
	cpu : entity work.processor port map(extPC, IMdata, DMdata, IMwrite, DMwrite, DMaddr, stall, clk);

	-- clk process
	clkgen: process
	begin
		clk <= '1';
		wait for 1 ns;
		clk <= '0';
		wait for 1 ns;
	end process;

	tester: process
	begin
		-- init values
		stall <= '1';
       		IMwrite <= '0';
        	DMwrite <= '1';
		-- put some data into the DM
		DMdata <= x"AAAAAAAA";
		DMwrite <= '1';
		DMaddr <= x"00000001";
		wait for 2 ns;
		DMdata <= x"BBBBBBBB";
		DMwrite <= '1';
		DMaddr <= x"00000002";
		wait for 2 ns;
		DMdata <= x"CCCCCCCC";
		DMwrite <= '1';
		DMaddr <= x"00000003";
		wait for 2 ns;
		DMdata <= x"FFFFFFFF";
		DMwrite <= '1';
		DMaddr <= x"00000004";
		wait for 2 ns;
		DMdata <= x"00000000";
		DMwrite <= '1';
		DMaddr <= x"00000005";
		wait for 2 ns;

		-- Now load program, start from address 1
		DMwrite <= '0';
		IMwrite <= '1';
		-- lw $1, 1($zero)
		extPC <= x"00000001";
		IMdata <= b"10001100000000010000000000000001";
		wait for 2 ns;
		-- sw $1, 6($zero)
		extPC <= x"00000002";
		IMdata <= b"10101100000000010000000000000110";
		wait for 2 ns;
		-- lw $2, 2($zero)
		extPC <= x"00000003";
		IMdata <= b"10001100000000100000000000000010";
		wait for 2 ns;
		-- add $3, $1, $2
		extPC <= x"00000004";
		IMdata <= b"00000000001000100001100000100000";
		wait for 2 ns;
		-- sub $4, $2, $1
		extPC <= x"00000005";
		IMdata <= b"00000000010000010010000000110000";
		wait for 2 ns;
		-- beq $1, $2, 100
		extPC <= x"00000006";
		IMdata <= b"00010000001000100000000001100100";
		wait for 2 ns;

		-- lw $2, 4($zero)
		extPC <= x"00000007";
		IMdata <= b"10001100000000100000000000000100";
		wait for 2 ns;
		-- nand $5, $1, $2
		extPC <= x"00000008";
		IMdata <= b"00000000001000100010100000000001";
		wait for 2 ns;
		-- andi $6, $2, 00FF
		extPC <= x"00000009";
		IMdata <= b"00001000010001100000000011111111";
		wait for 2 ns;
		-- ori $7, $1, 00FF
		extPC <= x"0000000A";
		IMdata <= b"00001100001001110000000011111111";
		wait for 2 ns;
		-- or $8, $1, $2
		extPC <= x"0000000B";
		IMdata <= b"00000000001000100100000000000010";
		wait for 2 ns;
		-- beq $1, $1 -0x000B
		extPC <= x"0000000C";
		IMdata <= b"00010000001000011111111111110101";
		wait for 2 ns;

-- Begin execution here
		wait for 2 ns;
		IMwrite <= '0';
		extPC <= x"00000000";
		wait for 2 ns;
		stall <= '0';

--allow enough time for processor to execute instructions
		wait for 100 ns;

	end process;
end behavioral;
