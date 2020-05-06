library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity system is
  port (
    clk,rst,INT:IN std_logic;
    INPORT:IN std_logic_vector(31 downto 0);
    OUTPort:OUT std_logic_vector(31 downto 0)
  ) ;
end system ;

architecture arch of system is
-----------------------------------------fetch stage signals------------------------------------ 
signal instruction:std_logic_vector(15 downto 0);
signal pcnew:std_logic_vector(31 downto 0);
signal probINTsignal,probRstSignal,RRIsignal:std_logic;--signals to propagte in the next stages.
------------------------------------------------------------------------------------------------

-----------------------------------------Decode stage signals------------------------------------ 
signal RegWriteinput,Swapinput,ZFToCheck:std_logic;
signal Mem_Wb_Rd,Mem_Wb_Rs: std_logic_vector(2 downto 0);
signal value1,value2: std_logic_vector(31 downto 0);
signal Target_Address,Rsrc,Rdst,instructionDecodeout: std_logic_vector(31 downto 0);
signal RegWrite,REGdstSignal,MemToReg,MemRd,MemWR: std_logic;
signal SP: std_logic_vector(1 downto 0);
signal ALU: std_logic_vector(3 downto 0);
signal PCWrite,IMM_EA,sign,CRR: std_logic;
signal In_enable,Out_enable,thirtyTwo_Sixteen,RRI,SWAP, CALL: std_logic;
signal Rs,Rt_from_fetch: std_logic_vector(2 downto 0);
------------------------------------------------------------------------------------------------

-----------------------------------------Execute stage signals------------------------------------ 
signal EXALUResult:std_logic_vector(31 downto 0);
signal EX_MEMRegisterRd:std_logic_vector(2 downto 0);
signal EX_MEMRegWrite,EX_MEMSWAP:std_logic;
signal RegDst :std_logic_vector(2 downto 0);
signal CCR:std_logic_vector(2 downto 0);
signal ZF:std_logic;
signal DataOut:std_logic_vector(31 downto 0);
signal AddrressEA_IMM:std_logic_vector(31 downto 0);

------------------------------------------------------------------------------------------------

-----------------------------------------Memory stage signals------------------------------------ 
signal MEMALUResult:std_logic_vector(31 downto 0);
signal MEM_WBRegisterRd:std_logic_vector(2 downto 0);
signal MEM_WBRegWrite,MEM_WBSWAP:std_logic;
------------------------------------------------------------------------------------------------


-----------------------------------------intermediate registers signals------------------------------------ 
signal IF_IDRegIN,IF_IDRegOut:std_logic_vector(50 downto 0);
signal ID_EXRegIN,ID_EXRegOUT: std_logic_vector(146 downto 0);
signal EX_MEMRegIN,EX_MEMRegOUT: std_logic_vector(114 downto 0);
signal MEM_WBRegIN,MEM_WBRegOUT: std_logic_vector(105 downto 0);
signal IF_IDFlush,ID_EXFlush,EX_MEMFlush,MEM_WBFlush:std_logic:='0';
signal IF_IDwrite,ID_EXwrite,EX_MEMwrite,MEM_WBwrite:std_logic:='1';
------------------------------------------------------------------------------------------------

begin
--------------------------------------------------------------Fetch ->> Decode------------------------------------------
Fetch:entity work.FetchStage  Generic map (wordSize=>16,PCSize=>32) 
port map(clk=>clk,reset=>rst,interrupt=>INT,instruction=>instruction,PCnew=>pcnew,RRI=>RRIsignal,intSignal=>probINTsignal,rstSignal=>probRstSignal);
IF_IDRegIN(15 downto 0) <=instruction;
IF_IDRegIN(47 downto 16) <=pcnew;
IF_IDRegIN(48) <=probINTsignal;
IF_IDRegIN(49) <=RRIsignal;
IF_IDRegIN(50) <=probRstSignal;
IF_ID:entity work.Reg  generic map(n=>51) port map(input=>IF_IDRegIN,en=>IF_IDwrite,rst=>rst,clk=>clk,output=>IF_IDRegOUT);
-----------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------Decode ->>Execute ------------------------------------------
Decode:entity work.Alldecoder Generic map (n=>32) 
port map (
    clk=>clk,
	IF_ID=>IF_IDRegOUT,
	RegWriteinput=>RegWriteinput,
	Swapinput=>Swapinput,
	Mem_Wb_Rd=>MEM_WBRegOUT(38 downto 36),Mem_Wb_Rs=>MEM_WBRegOUT(35 downto 33),
	Rt_from_fetch =>instruction(10 downto 8),
    value1=>value1,value2=>value2,
    Target_Address=>Target_Address,
	Rsrc=>Rsrc,
	Rdst=>Rdst ,
	instruction=>instructionDecodeout,
	RegWrite=>RegWrite,
	RegDST=>REGdstSignal,
	MemToReg=>MemToReg,
	MemRd=>MemRd,
	MemWR=>MemWR,
	SP=>SP,
	ALU=>ALU,
	PCWrite=>PCWrite,
	IMM_EA=>IMM_EA,
	sign=>sign,
	CRR=>CRR,
	In_enable=>In_enable,
	Out_enable=>Out_enable,
	thirtyTwo_Sixteen=>thirtyTwo_Sixteen,
	RRI=>RRI,
	SWAP=>SWAP,
	CALL=>CALL,
	Rs =>Rs);
ID_EX:entity work.Reg  generic map(n=>147) port map(input=>ID_EXRegIN,en=>ID_EXwrite,rst=>rst,clk=>clk,output=>ID_EXRegOUT);
	
---------------------------------------ID_EX Buffer -----------------------------------------------------------------
ID_EXRegIN(31 downto 0) <= Rsrc; --Rscr1 
ID_EXRegIN(63 downto 32) <= Rdst; -- Rscr2 
ID_EXRegIN(95 downto 64) <=instructionDecodeout;
ID_EXRegIN(127 downto 96) <= pcnew; --PC after incremented 

ID_EXRegIN(143) <= RRI; --RRI signal 
ID_EXRegIN(144) <= SWAP;
ID_EXRegIN(145) <= CALL;
ID_EXRegIN(146) <= probINTsignal;
ID_EXRegIN(128) <=MemToReg;
ID_EXRegIN(129) <=RegWrite;
ID_EXRegIN(130) <=Out_enable;
ID_EXRegIN(134 downto 131) <=ALU;
ID_EXRegIN(135) <=sign;
ID_EXRegIN(136) <=IMM_EA;
ID_EXRegIN(137) <=REGdstSignal;
ID_EXRegIN(138) <=In_enable;
ID_EXRegIN(139) <=MemRd;
ID_EXRegIN(140) <=MemWR;
ID_EXRegIN(142 downto 141) <=SP;


-----------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------Execute ->> Memory ------------------------------------------
Execute:entity work.ExeStage port map(clk=>clk,rst=>rst,INT=>INT,
ID_EX=>ID_EXRegOUT,
EXALUResult=>EXALUResult,MEMALUResult=>MEMALUResult,INPORTValue=>INPORT,
MEM_WBRegisterRd=>MEM_WBRegisterRd,EX_MEMRegisterRd=>EX_MEMRegisterRd,
EX_MEMRegWrite=>EX_MEMRegWrite,MEM_WBRegWrite=>MEM_WBRegWrite,EX_MEMSWAP=>EX_MEMSWAP,MEM_WBSWAP=>MEM_WBSWAP,
RegDst=>EX_MEMRegIN(102 downto 100),CCR=>EX_MEMRegIN(107 downto 105),RsReg=>EX_MEMRegIN(35 downto 33),WBsignals=>EX_MEMRegIN(114 downto 112),
MEMSignals=>EX_MEMRegIN(111 downto 108),ZF=>ZFToCheck,SWAP=>EX_MEMRegIN(32),
INTSignal=>EX_MEMRegIN(103),RRI=>EX_MEMRegIN(104),DataOut=>EX_MEMRegIN(67 downto 36),
AddrressEA_IMM=>EX_MEMRegIN(99 downto 68),SRC2out=>EX_MEMRegIN(31 downto 0));

EX_MEM:entity work.Reg  generic map(n=>115) port map(input=>EX_MEMRegIN,en=>EX_MEMwrite,rst=>rst,clk=>clk,output=>EX_MEMRegOUT);
-----------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------Memory ->> Write Back ------------------------------------------
MemoryStage:entity work.memory port map(reset=>rst, clk=>clk,

EX_MEM=>EX_MEMRegOUT,Rsrc2=>MEM_WBRegIN(31 downto 0),ALUresult=>MEM_WBRegIN(105 downto 74), MemoryReuslt=>MEM_WBRegIN(73 downto 42) ,SWAP=>MEM_WBRegIN(32),Rs=>MEM_WBRegIN(35 downto 33),Rd=>MEM_WBRegIN(38 downto 36),WBsignals=>MEM_WBRegIN(41 downto 39));


MEM_WB:entity work.Reg  generic map(n=>106) port map(input=>MEM_WBRegIN,en=>MEM_WBwrite,rst=>rst,clk=>clk,output=>MEM_WBRegOUT);

WBStage:entity work.WBStage port map (clk=>clk,rst=>rst,MEM_WB=>MEM_WBRegOUT,RegWriteToRegisterFile=>RegWriteinput,Swap=>Swapinput,PortOut=>OUTPort,Value1=>value1,Value2=>value2);
-----------------------------------------------------------------------------------------------------------------------------------------






-- process(clk,rst)
-- begin 
--     if(falling_edge(clk))then
        
--     end if;
-- end process;

end architecture ; -- arch