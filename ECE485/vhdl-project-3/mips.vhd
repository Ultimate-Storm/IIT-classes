library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regFile is
	port(
	regA : out std_logic_vector(31 downto 0);
	regB : out std_logic_vector(31 downto 0);
	selA : in std_logic_vector(3 downto 0);
	selB : in std_logic_vector(3 downto 0);
	wData : in std_logic_vector(31 downto 0);
	registerWrite : in std_logic;
	selW : in std_logic_vector(3 downto 0);
	clk : in std_logic);
end regFile;

architecture behavioral of regFile is
type reg_arr is array(0 to 15) of std_logic_vector(31 downto 0);
signal rData : reg_arr;
begin
	with selA
		select regA <= x"00000000" when b"0000",
		rData(to_integer(unsigned(selA))) when others;
	with selB
		select regB <= x"00000000" when b"0000",
		rData(to_integer(unsigned(selB))) when others;
	
	wrProc: process(clk) is
	begin
		if falling_edge(clk) then
		if(registerWrite = '1') then
			rData(to_integer(unsigned(selW))) <= wData;
		end if;
		end if;
	end process;
end behavioral;

---

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
	port(
		inst_in : in std_logic_vector(5 downto 0);
		func : in std_logic_vector(5 downto 0);
		stall : in std_logic;
		branch : out std_logic;
		reg_dest : out std_logic;
		reg_write : out std_logic;
		ALU_src : out std_logic;
		ALU_op : out std_logic_vector(2 downto 0);
		mem_write : out std_logic;
		mem_to_reg : out std_logic
	);
end control;

architecture behavioral of control is
	signal branch_o, reg_dest_o, reg_write_o, ALU_src_o, mem_write_o, mem_to_reg_o : std_logic;
	signal ALU_op_o : std_logic_vector(2 downto 0);
	signal branch_f, reg_dest_f, reg_write_f, ALU_src_f, mem_write_f, mem_to_reg_f : std_logic;
	signal ALU_op_f : std_logic_vector(2 downto 0);
begin	
	-- set intermediate signals incase of r-type instruction
	with func select
		branch_f <= '0' when "100000",	--add
			'0' when "110000",	--sub
			'0' when "000001",	--nand
			'0' when "000010",	--or
			'0' when others;
	with func select
		reg_dest_f <= '1' when "100000",	--add
			'1' when "110000",	--sub
			'1' when "000001",	--nand
			'1' when "000010",	--or
			'Z' when others;
	with func select
		reg_write_f <= '1' when "100000",	--add
			'1' when "110000",	--sub
			'1' when "000001",	--nand
			'1' when "000010",	--or
			'Z' when others;
	with func select
		ALU_src_f <= '0' when "100000",	--add
			'0' when "110000",	--sub
			'0' when "000001",	--nand
			'0' when "000010",	--or
			'Z' when others;
	with func select
		ALU_op_f <= "000" when "100000",	--add
			"001" when "110000",	--sub
			"010" when "000001",	--nand
			"100" when "000010",	--or
			"ZZZ" when others;
	with func select
		mem_write_f <= '0' when "100000",	--add
			'0' when "110000",	--sub
			'0' when "000001",	--nand
			'0' when "000010",	--or
			'Z' when others;
	with func select
		mem_to_reg_f <= '1' when "100000",	--add
			'1' when "110000",	--sub
			'1' when "000001",	--nand
			'1' when "000010",	--or
			'Z' when others;

	-- set intermediate signals incase of non r-type instruction
	with inst_in select
		branch_o <= '0' when "100011",	--lw
			'0' when "101011",	--sw
			'1' when "000100",	--beq
			'0' when "000010",	--andi
			'0' when "000011",	--ori
			'0' when others;
	with inst_in select
		reg_dest_o <= '0' when "100011",	--lw
			'0' when "101011",	--sw
			'0' when "000100",	--beq
			'0' when "000010",	--andi
			'0' when "000011",	--ori
			'Z' when others;
	with inst_in select
		reg_write_o <= '1' when "100011",	--lw
			'0' when "101011",	--sw
			'0' when "000100",	--beq
			'1' when "000010",	--andi
			'1' when "000011",	--ori
			'Z' when others;
	with inst_in select
		ALU_src_o <= '1' when "100011",	--lw
			'1' when "101011",	--sw
			'0' when "000100",	--beq
			'1' when "000010",	--andi
			'1' when "000011",	--ori
			'Z' when others;
	with inst_in select
		ALU_op_o <= "000" when "100011",	--lw
			"000" when "101011",	--sw
			"001" when "000100",	--beq
			"011" when "000010",	--andi
			"100" when "000011",	--ori
			"ZZZ" when others;
	with inst_in select
		mem_write_o <= '0' when "100011",	--lw
			'1' when "101011",	--sw
			'0' when "000100",	--beq
			'0' when "000010",	--andi
			'0' when "000011",	--ori
			'Z' when others;
	with inst_in select
		mem_to_reg_o <= '0' when "100011",	--lw
			'1' when "101011",	--sw
			'1' when "000100",	--beq
			'1' when "000010",	--andi
			'1' when "000011",	--ori
			'Z' when others;

	-- select from intermediate signals
	with inst_in select
		branch <= branch_f when "000000",
			branch_o when others;
	with inst_in select
		reg_dest <= reg_dest_f when "000000",
			reg_dest_o when others;
	with inst_in select
		reg_write <= reg_write_f when "000000",
			reg_write_o when others;
	with inst_in select
		ALU_src <= ALU_src_f when "000000",
			ALU_src_o when others;
	with inst_in select
		ALU_op <= ALU_op_f when "000000",
			ALU_op_o when others;
	with inst_in select
		mem_write <= mem_write_f when "000000",
			mem_write_o when others;
	with inst_in select
		mem_to_reg <= mem_to_reg_f when "000000",
			mem_to_reg_o when others;
end behavioral;

---

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataMem is
	port(
	data : out std_logic_vector(31 downto 0);
	sel : in std_logic_vector(31 downto 0);
	wData : in std_logic_vector(31 downto 0);
	memWrite : in std_logic;
	clk : in std_logic);
end dataMem;

architecture behavioral of dataMem is
type mem_arr is array(0 to 255) of std_logic_vector(31 downto 0);
signal mData : mem_arr;
begin
	data <= mData(to_integer(resize(unsigned(sel),8)));
	
	wrProc: process(clk) is
	begin
		if falling_edge(clk) then
		if(memWrite = '1') then
	        mData(to_integer(resize(unsigned(sel),8))) <= wData;
		end if;
		end if;
	end process;
end behavioral;



---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port(
    inA : in std_logic_vector(31 downto 0);
    inB : in std_logic_vector(31 downto 0);
    ctl : in std_logic_vector(2 downto 0);
    res : out std_logic_vector(31 downto 0));
end ALU;

architecture behavioral of ALU is
signal add : std_logic_vector(31 downto 0);
signal sub : std_logic_vector(31 downto 0);
signal andres : std_logic_vector(31 downto 0);
signal nandres : std_logic_vector(31 downto 0);
signal orres : std_logic_vector(31 downto 0);
    begin
    add <= std_logic_vector(signed(inA)+signed(inB));
    sub <= std_logic_vector(signed(inA)-signed(inB));
    andres <= std_logic_vector(unsigned(inA) and unsigned(inB));
    nandres <= std_logic_vector(not(unsigned(inA) and unsigned(inB)));
    orres <= std_logic_vector(unsigned(inA) or unsigned(inB));

	-- Multiplexer
	with ctl select
		res <= add when "000",
			sub when "001",
			nandres when "010",
			andres when "011",
			orres when "100",
			"00000000000000000000000000000000" when others;
end behavioral;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity processor is
    port(
    extPC : in std_logic_vector(31 downto 0);
    IMdata : in std_logic_vector(31 downto 0);
    DMdata : in std_logic_vector(31 downto 0);
    IMwrite : in std_logic;
    DMwrite : in std_logic;
    DMaddr : in std_logic_vector(31 downto 0);
    stall : in std_logic;
    clk : in std_logic
);
end processor;

architecture behavioral of processor is
signal im_wrEn,im_clk : std_logic;
signal im_data,im_addr,im_wData : std_logic_vector(31 downto 0);
signal dm_wrEn,dm_clk : std_logic;
signal dm_data,dm_addr,dm_wData : std_logic_vector(31 downto 0);
signal PC : std_logic_vector(31 downto 0);
signal regA,regB,wData : std_logic_vector(31 downto 0);
signal selA,selB,selW : std_logic_vector(3 downto 0);
signal aluCtl : std_logic_vector(2 downto 0);
signal regWrite, regDest, regClk, dm_write, aluSrc,memtoreg : std_logic;
signal aluA,aluB,aluRes : std_logic_vector(31 downto 0);
signal branch, branchI, zero : std_logic := '0';
signal braAddr : std_logic_vector(15 downto 0);
signal op_code, func : std_logic_vector(5 downto 0);

begin
	IM : entity work.dataMem port map(im_data,im_addr,im_wData,im_wrEn,im_clk);
	DM : entity work.dataMem port map(dm_data,dm_addr,dm_wData,dm_wrEn,dm_clk);
    RF : entity work.regFile port map(regA,regB,selA,selB,wData,regWrite,selW,regClk);
    ALU : entity work.ALU port map(aluA, aluB, aluCtl, aluRes);
	CTRL : entity work.control port map(op_code, func, stall, branchI, regDest, regWrite, aluSrc, aluCtl, dm_write, memtoreg);
    
    --all clocks synced
    im_clk <= clk;
    dm_clk <= clk;
    regClk <= clk;

    im_wData <= IMData;
    im_wrEn <= IMWrite;
    --allow testbench to initialize
    process(clk)
    begin
    if(rising_edge(clk)) then
        if(stall = '1') then
            PC <= extPC;
        elsif(branch = '1') then
            PC <= std_logic_vector(unsigned(PC) + (unsigned(resize(signed(braAddr), 32))));
        else
            PC <= std_logic_vector(unsigned(PC) + x"1");
        end if;
    end if;
    end process;
    braAddr <= im_data(15 downto 0);
    im_addr <= PC;
    aluA <= regA;
    with aluSrc 
        select aluB <= regB when '0',
        std_logic_vector(unsigned(resize(signed(im_data(15 downto 0)), 32))) when '1',
        x"00000000" when others;
    with regDest
        select selW <= im_data(19 downto 16) when '0',
        im_data(14 downto 11) when '1',
        "ZZZZ" when others;
    with stall
        select dm_addr <=  DMaddr when '1',
        aluRes when others;
    with stall
        select dm_wData <= DMdata when '1',
        regB when others;
    with stall
        select dm_wrEn <= DMWrite when '1',
		dm_write when others;
            
    with memtoreg
        select wData <= aluRes when '1',
        dm_data when others;
    
    with aluRes
        select zero <= '1' when x"00000000",
        '0' when others;
    
    branch <= branchI and zero;

    op_code <= im_data(31 downto 26);
    func <= im_data(5 downto 0);

    selA <= im_data(24 downto 21);
    selB <= im_data(19 downto 16);
end behavioral;
