/*
	DUs in file in order
		ram
	
	ram 
		a0  is address input
		i0  is data input
		o0  is data output
		we  is write enable
		clk is synchronization
		
		64KiB of data, byte addressable
		access must be 2B aligned 
		unaligned memory access is rounded down to first aligned 
		meaning LSb is discarded when using a0 
		
		so in practice behaves like 32Ki of 16bit words

		default value of data is program
*/


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram IS
	PORT(
		a0  : IN  std_ulogic_vector(15 DOWNTO 0) := x"0000";
		i0s : IN  std_ulogic_vector(15 DOWNTO 0);
		o0s : OUT std_ulogic_vector(15 DOWNTO 0);
		o0d : OUT std_ulogic_vector(31 DOWNTO 0) := x"00000000";

		we  : IN  std_ulogic := '0';
		rdy : OUT std_ulogic := '0';
		clk : IN  std_ulogic);
END ENTITY ram;

ARCHITECTURE behav OF ram IS 
	TYPE arr IS ARRAY(16383 DOWNTO 0) OF std_ulogic_vector(31 DOWNTO 0);
	SIGNAL data : arr := (
	--fib.asm
	/*
		00 => x"28002901", 01 => x"2F078F00", 02 => x"A60A0205", 03 => x"00250158", 04 => x"CF01A305",
		05 => x"38500000", 06 => x"0F000000",
	*/
	--fact.asm
	/*
		00 => x"A7198900", 01 => x"A5052800", 02 => x"A70A0205", 03 => x"C9010058", 04 => x"C901A107",
		05 => x"B700074C", 06 => x"77008801", 07 => x"A6157000", 08 => x"C801AB0B", 09 => x"7900AF01",
		10 => x"A7162801", 11 => x"7F0002ED", 12 => x"B7002806", 13 => x"AF0B3850", 14 => x"0F000000",
	*/
	--sort.asm		
	/*
		00 => x"A7278900", 01 => x"A5052800", 02 => x"A70A0205", 03 => x"C9010058", 04 => x"C901A107",
		05 => x"B7008A00", 06 => x"B6000306", 07 => x"0327C002", 08 => x"C102CA02", 09 => x"A70B0605",
		10 => x"06388902", 11 => x"B6000205", 12 => x"0305C302", 13 => x"04460566", 14 => x"04B1A620",
		15 => x"05470467", 16 => x"C202C302", 17 => x"03D1A41A", 18 => x"C902A113", 19 => x"B7002EA4",
		20 => x"2801297B", 21 => x"AF01F001", 22 => x"F80100C7", 23 => x"CE028E96", 24 => x"A3292896",
		25 => x"29C82A10", 26 => x"AF0B2896", 27 => x"2910AF13", 28 => x"30963198", 29 => x"329A339C",
		30 => x"349E35A0", 31 => x"36A237A4", 32 => x"0F000000",
	*/
	--pipeline_easy.asm
	/*
		00 => x"28002901", 01 => x"2A022B03", 02 => x"2C042D05", 03 => x"2E062F07", 04 => x"00380158",
		05 => x"02780398", 06 => x"04B805D8", 07 => x"06F80718", 08 => x"F001F101", 09 => x"F201F301",
		10 => x"F401F501", 11 => x"F601F701", 12 => x"0F000000",
	*/
	--pipeline_alu_dep.asm
	/*
		00 => x"29002810", 01 => x"F0020205", 02 => x"F8020305", 03 => x"C001C802", 04 => x"F8010405",
		05 => x"0F000000",
	*/
	--pipeline_stresstest.asm
	/*
		00 => x"28050105", 01 => x"F0026C01", 02 => x"2A00FA07", 03 => x"C0010010", 04 => x"CA01A306",
		05 => x"6C01048C", 06 => x"6A14B700", 07 => x"2D098504", 08 => x"3D643664", 09 => x"05BD6815",
		10 => x"AF0E0F00",
	*/
	--matmult.asm
	/*
		00 => x"A7422A00", 01 => x"8900A207", 02 => x"0218C901", 03 => x"A1040045", 04 => x"B7002909",
		05 => x"C0100107", 06 => x"C802C901", 07 => x"A10BB700", 08 => x"074C7700", 09 => x"2B032F00",
		10 => x"70007100", 11 => x"00060126", 12 => x"AF010718", 13 => x"79007800", 14 => x"C002C106",
		15 => x"CB01A114", 16 => x"00E57F00", 17 => x"02EDB700", 18 => x"074C7700", 19 => x"2C037400",
		20 => x"70007100", 21 => x"2B037300", 22 => x"70007100", 23 => x"7200AF10", 24 => x"7A000047",
		25 => x"C2027900", 26 => x"C1027800", 27 => x"7B00CB01", 28 => x"A12B7900", 29 => x"7800C006",
		30 => x"7C00CC01", 31 => x"A1277F00", 32 => x"02EDB700", 33 => x"6C012800", 34 => x"AF096C02",
		35 => x"2800AF09", 36 => x"6C012800", 37 => x"6C022900", 38 => x"6C032A00", 39 => x"AF246C03",
		40 => x"2F0000E6", 41 => x"C70201E6", 42 => x"C70202E6", 43 => x"C70203E6", 44 => x"C70204E6",
		45 => x"C70205E6", 46 => x"C70206E6", 47 => x"C70207E6", 48 => x"0F000000",
	*/
	--sort_instr.asm
	/*
		00 => x"A71D8A00", 01 => x"B6000306", 02 => x"0327C002", 03 => x"C102CA02", 04 => x"A7010605",
		05 => x"06388902", 06 => x"B6000205", 07 => x"0305C302", 08 => x"04460566", 09 => x"04B1A616",
		10 => x"05470467", 11 => x"C202C302", 12 => x"03D1A410", 13 => x"C902A109", 14 => x"B7002EA4",
		15 => x"2801807B", 16 => x"F001F801", 17 => x"00C7CE02", 18 => x"8E96A31F", 19 => x"289629C8",
		20 => x"2A10AF01", 21 => x"28962910", 22 => x"AF093096", 23 => x"3198329A", 24 => x"339C349E",
		25 => x"35A036A2", 26 => x"37A40F00",
	*/
	--matmult_instr.asm
--	/*
		00 => x"A7342909", 01 => x"C0100107", 02 => x"C802C901", 03 => x"A103B700", 04 => x"07060526",
		05 => x"07B0C002", 06 => x"C1060406", 07 => x"052604B0", 08 => x"0798C002", 09 => x"C1060406",
		10 => x"052604B0", 11 => x"07980747", 12 => x"B700074C", 13 => x"770039C8", 14 => x"C10239CA",
		15 => x"C10239CC", 16 => x"2E0338FE", 17 => x"31C8AF08", 18 => x"C20230FE", 19 => x"31CAAF08",
		20 => x"C20230FE", 21 => x"31CCAF08", 22 => x"C20230FE", 23 => x"C006CE01", 24 => x"A1217F00",
		25 => x"02EDB700", 26 => x"6C012800", 27 => x"AF016C02", 28 => x"2800AF01", 29 => x"6C012800",
		30 => x"6C022900", 31 => x"6C032A00", 32 => x"AF196C03", 33 => x"2F0000E6", 34 => x"C70201E6",
		35 => x"C70202E6", 36 => x"C70203E6", 37 => x"C70204E6", 38 => x"C70205E6", 39 => x"C70206E6",
		40 => x"C70207E6", 41 => x"0F000000",
--	*/
	--oooe_simplest.asm
	/*
		00 => x"28002901", 01 => x"2A022B03", 02 => x"00380278", 03 => x"01190279", 04 => x"005D017D",
		05 => x"00180138", 06 => x"0F000000",
	*/
	--oooe_alu_conflict_0.asm
	/*
		00 => x"28012902", 01 => x"2A042B08", 02 => x"00580318", 03 => x"02380218", 04 => x"0F000000",
	*/
	--oooe_alu_conflict_1.asm
	/*
		00 => x"28012902", 01 => x"2A042B08", 02 => x"00580318", 03 => x"02380278", 04 => x"0F000000",
	*/
	--oooe_alu_conflict_2.asm
	/*
		00 => x"28012902", 01 => x"2A042B08", 02 => x"00580318", 03 => x"02780465", 04 => x"0F000000",
	*/
	--oooe_alu_conflict_3.asm
	/*
		00 => x"28012902", 01 => x"2A042B08", 02 => x"C0010118", 03 => x"02380358", 04 => x"2C102D20",
		05 => x"00000000", 06 => x"0F000000",
	*/
	--oooe_memory_0.asm
	/*
		00 => x"28642968", 01 => x"38643968", 02 => x"35643668", 03 => x"0F000000",
	*/
	--oooe_branch_aligned.asm
	/*
		00 => x"28012902", 01 => x"2A042B08", 02 => x"0351A10A", 03 => x"2C642D68", 04 => x"0F000000",
		05 => x"2C102D20", 06 => x"0F000000",
	*/
	--oooe_branch_misaligned.asm
	/*
		00 => x"28012902", 01 => x"2A042B08", 02 => x"0351A109", 03 => x"2C642D68", 04 => x"0F002C10",
		05 => x"2D200F00",
	*/
	--oooe_fib.asm
	/*
		00 => x"28002F07", 01 => x"29018F00", 02 => x"A60C0000", 03 => x"02050025", 04 => x"0158CF01",
		05 => x"A3060000", 06 => x"38500F00",
	*/
	OTHERS => x"00000000"
	);

	SIGNAL addr     : integer RANGE 16383 DOWNTO 0;
	SIGNAL mem_data : std_ulogic_vector(31 DOWNTO 0) := x"00000000";
	SIGNAL ms_half  : std_ulogic;

	SIGNAL mem_out     : std_ulogic_vector(31 DOWNTO 0) := x"00000000";
	SIGNAL mem_in      : std_ulogic_vector(31 DOWNTO 0);
BEGIN
	--LSb is ignored
	--next bit is one decides whether data is in first or second half of memory
	addr <= to_integer(unsigned(a0(15 DOWNTO 2)));

	--most significant half 
	--in xAAAABBBB
	--its half denoted by AAAA
	ms_half  <= NOT a0(1);
	mem_data <= data(addr);

	mem_in <= mem_data(31 DOWNTO 16) & i0s WHEN ms_half = '0'
	     ELSE i0s & mem_data(15 DOWNTO  0);

	data(addr) <= mem_in WHEN we = '1' AND rising_edge(clk)
	         ELSE UNAFFECTED;

	mem_out <= mem_data; 

	o0s <= mem_out(31 DOWNTO 16) WHEN ms_half = '1'
	  ELSE mem_out(15 DOWNTO  0); 
	o0d <= mem_out;

	--models delay
	--rdy <= '1' AFTER 10 NS, '0' AFTER 10.5   NS WHEN rising_edge(clk)
	--  ELSE UNAFFECTED;
	--stub 
	rdy <= '1';

END ARCHITECTURE behav; 

