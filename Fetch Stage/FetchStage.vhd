Library IEEE;
use ieee.std_logic_1164.all;


ENTITY FetchStage IS
    Generic(wordSize: integer :=16;
            PCSize: integer :=32);
			
	PORT(
            clk: in STD_LOGIC;
			reset: in std_logic:='0';
			interrupt,pcWrite,MemoryReadSignal: in std_logic;
			DecodePC,DecodeTargetAddress,MemoryPC:IN std_logic_vector(PCSize-1 downto 0);
			T_NT:IN std_logic_vector(1 downto 0);
			INPORTValue:IN std_logic_vector(31 downto 0);

--			instruction: in STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0);
		
			instruction: out STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0);
			InstrPC,INPORTValueFetchOut : out std_logic_vector(PCSize-1 downto 0);
			intSignal,rstSignal,RRI,IF_IDFlush : out std_logic --interrupt signal output 
			  --restet signal output 
		);

END FetchStage;


ARCHITECTURE FetchStageArch of FetchStage is

SIGNAL tmp,tempInstruction:std_logic_vector(15 downto 0); --not used just dummpy variable
signal dummy,JZ,UnconditionBranch,RRISignal,RRIPCWrite,ActualPCWrite,IF_IDFLUSHSig: std_logic;
signal tempPCnew: STD_LOGIC_VECTOR(PCSize-1 DOWNTO 0);
signal PCReg,PCRegValue: STD_LOGIC_VECTOR(PCSize-1 DOWNTO 0);
signal State:std_logic_vector(1 downto 0);
signal currentPCIndex:std_logic_vector(9 downto 0);
signal oldTargetAddress:std_logic_vector(31 downto 0);--in case of wrong prediction.
BEGIN

   instruction_memory: entity work.ram generic map(1) port map (clk,'0','1',PCRegValue,tmp,tempInstruction);
  
   --PCnew is a value of pc after incremented 
   	--PCAdder:entity work.adder generic map(PCSize)port map(PCReg,"00000000000000000000000000000001",'0',tempPCnew,dummy);
	
	PC_Reg: entity work.Reg(RegFalling) generic map(32) port map(input=>tempPCnew,en=>ActualPCWrite,rst=>'0',clk=>clk,output=>PCRegValue);
	intSignal <=interrupt;

	oldTargetAddress<=DecodeTargetAddress when jz='1' and falling_edge(clk);

	INPORTValueFetchOut<=INPORTValue when reset ='0' else (others=>'0') when reset='1' ;
	--reset signal output 
	rstSignal <=reset;
	RRI<=RRISignal;
	instruction<=(others=>'0') when reset = '1' else tempInstruction when reset ='0';
	PCReg <="00000000000000000000000000001111" when (reset ='1') else PCRegValue when reset='0';
	InstrPC<=PCReg ;
	ActualPCWrite<=RRIPCWrite or pcWrite;
	currentPCIndex<=PCRegValue(9 downto 0) when rising_edge(clk);
	IF_IDFlush<=IF_IDFLUSHSig;
	DecisionCircuit:entity work.decision port map(PCreg=>PCReg,DecodePC=>DecodePC,TargetAddress=>DecodeTargetAddress,oldTargetAddress=>oldTargetAddress,MemoryPC=>MemoryPC,
	rst=>reset,clk=>clk,ReadFromMemorySignal=>MemoryReadSignal,JZ=>JZ,UnconditionBranch=>UnconditionBranch,
	T_NT=>T_NT,State=>State,IF_IDFLUSH=>IF_IDFLUSHSig,
	
	PCnext=>tempPCnew);

	CheckBranch:entity work.Check_Branches port map(OpCode=>instruction(15 downto 11),
	JZ=>JZ,unconditionalBranch=>UnconditionBranch);

	CheckRRI:entity work.Check_RRI port map(OpCode=>instruction(15 downto 11),
	
	RRI=>RRISignal,
	PCwrite=>RRIPCWrite);

	Predicition:entity work.predictionblock port map(
		clk=>clk,JZ=>JZ,
		T_NT=>T_NT,
		--T/NT --> 00 Taken ,01 Not Taken , 10 not jz,11 not jz
		--if not jz then reset state
		CurrentPCIndex=>currentPCIndex,DecodePCIndex=>DecodePC(9 downto 0),--read index from current pc ,, write index from decodepc to write new state.
		IF_IDFlush=>IF_IDFLUSHSig,state=>State);--Read State To decision circuit)
END ARCHITECTURE;