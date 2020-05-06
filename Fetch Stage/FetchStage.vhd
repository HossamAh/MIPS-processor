Library IEEE;
use ieee.std_logic_1164.all;


ENTITY FetchStage IS
    Generic(wordSize: integer :=16;
            PCSize: integer :=32);
			
	PORT(
            clk: in STD_LOGIC;
			reset: in std_logic:='0';
			interrupt: in std_logic:='0';
 
			instruction: out STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0);
			PCnew : out std_logic_vector(PCSize-1 downto 0);
			intSignal,rstSignal,RRI : out std_logic --interrupt signal output 
			  --restet signal output 
		);

END FetchStage;


ARCHITECTURE FetchStageArch of FetchStage is

SIGNAL tmp:std_logic_vector(15 downto 0); --not used just dummpy variable
signal dummy: std_logic;
signal tempPCnew: STD_LOGIC_VECTOR(PCSize-1 DOWNTO 0);
signal PCReg: STD_LOGIC_VECTOR(PCSize-1 DOWNTO 0):="00000000000000000000000000001010";
BEGIN

   instruction_memory: entity work.ram generic map(1) port map (clk,'0','1',PCReg,tmp,instruction);
  --PCnew is a value of pc after incremented 
   PCAdder:entity work.adder generic map(PCSize)port map(PCreg,"00000000000000000000000000000001",'0',tempPCnew,dummy);

	intSignal <=interrupt;
	--reset signal output 
	rstSignal <=reset;
	RRI<='0';
	process(CLK)
	begin
	if(falling_edge(CLK))then 
		PCReg <=tempPCnew;
		PCnew<=tempPCnew;
	end if;
	end process;


END ARCHITECTURE;