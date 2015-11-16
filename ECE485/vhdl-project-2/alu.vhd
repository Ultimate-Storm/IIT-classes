library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
port(
		clk : in std_logic;
		s	: in std_logic;
		a,b : in signed(7 downto 0);
		op  : in unsigned(2 downto 0);
		y	: out signed(7 downto 0)

		);
end alu8;

architecture Behavioral of alu8 is

begin
process(clk)
begin
	if(rising_edge(clk)) then
		case op is 
			when "000" =>
				y <= a AND b;
			when "001" =>
				y <= a OR b;
			when "010" =>
				y <= a+ b;
			when "011" =>
				if(a < b) then
					y <= "11111111";
				else
					y <= "00000000";
				end if;
			when "100" =>
				y <= a-b;
			when "101" =>
				y <= a XOR b;
			when "110" =>
				if s = '1' then
					y <= SHIFT_LEFT(a,1);
				else 
					y <= SHIFT_LEFT(b,1);
				end if;
			when "111" =>
				if s = '1' then
					y <= SHIFT_RIGHT(a,1);
				else 
					y <= SHIFT_RIGHT(b,1);
				end if;
			when others =>
				NULL; --default case
		end case;
	end if;
end process;

end Behavioral;