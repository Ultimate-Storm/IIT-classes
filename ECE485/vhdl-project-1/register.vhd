library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_16 is
	port(
		outReg1			: out	std_logic_vector(15 downto 0);
		outReg2			: out	std_logic_vector(15 downto 0); 
		writeReg		: in 	std_logic_vector(2 downto 0);		
		writeData		: in 	std_logic_vector(15 downto 0);
		inReg1			: in 	std_logic_vector(2 downto 0);
		inReg2			: in 	std_logic_vector(2 downto 0);
		writeEnable : in 	std_logic;
		clk					: in 	std_logic	
	);
end register_16;


architecture behavioral of register_16 is
	type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
	signal registers : registerFile;
begin
	regFile : process (clk)	 is
	begin
		if rising_edge(clk) then
			outReg1 <= registers(to_integer(unsigned(inReg1)));
			outReg2 <= registers(to_integer(unsigned(inReg2)));
			if writeEnable = '1' then
				registers(to_integer(unsigned(writeReg))) <= writeData;
			end if;			
		end if;				
	end process;
end behavioral;