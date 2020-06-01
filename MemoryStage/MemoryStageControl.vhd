library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryStageControl is
  port (
    clk,INT,RST,CALL,RET,RTI,WRIn,RDIn,INTHandler,RTIHandler,RETHandler,CALLHandler:IN STD_LOGIC; 
    ALUdata,CRRFlags,AddressIn,MEMOUT:IN std_logic_vector(31 downto 0);
    SPIN:IN std_logic_vector(1 downto 0);--interrupt handled from system and become 11 when interrupt is come and the signal reach the memory stage 
    DataToWrite,Address,MemoryPC,FlagsOut:OUT std_logic_vector(31 downto 0);
    SPType:OUT std_logic_vector(1 downto 0);
    WriteSignal,ReadSignal,ResumeSignal,MemoryReadSignal,spEnable,RTIFlagsEnable:OUT STD_LOGIC
  ) ;
end MemoryStageControl ;

architecture arch of MemoryStageControl is
signal INTCounterValue,RTICounterValue,sp:std_logic_vector(1 downto 0):="00";
signal CALLCounterValue,RETCounterValue:STD_LOGIC;
signal INTcounterEnable,INTCounterReset,RTIcounterEnable,RTICounterReset,CALLcounterEnable,CALLCounterReset,RETcounterEnable,RETCounterReset:STD_LOGIC;
signal RETEn,RTIEn,INTEn,CALLEn:STD_LOGIC;
signal WR,RD:STD_LOGIC;
begin
    INTEn <= INTHandler and INT;
    RTIEn <= RTIHandler and RTI;
    RETEn <= RETHandler and RET;
    CALLEn<=CALL;

    DataToWrite<= std_logic_vector(unsigned(ALUdata)+1) when CALLEn ='1' 
    else ALUdata when INTEn='1' and INTCounterValue="00" 
    else CRRFlags when INTEn ='1' and INTCounterValue="10"
    else ALUdata;
    
    INTCounterEnable <= INTEn;
    INTCounterReset <= not INTEn; 
    
    RTICounterEnable <= RTIEn;
    RTICounterReset <= not RTIEn;
    RTIFlagsEnable<= '1' when RTIEn='1' and RTICounterValue = "01" else '0' ;


    CALLCounterEnable <= CALLEn;
    CALLCounterReset <= not CALLEn;

    RETCounterEnable <= CALLEn;
    RETCounterReset <= not CALLEn;

    sp<="00" when CALLEn='1'  
    else "01" when RETEn ='1' and RETCounterValue='0'
    else "01" when RTIEn ='1'  and RTICounterValue="00"
    else "01" when RTIEn ='1'  and RTICounterValue="01"
    else "00" when INTEn ='1'  and INTCounterValue="00"
    else "10" when INTEn ='1'  and INTCounterValue="01"
    else "00" when INTEn ='1'  and INTCounterValue="10"
    else "10" when RST ='1' 
    else SPIN;
    
    SPType<=sp;

    spEnable <= '1' when RST='1' or (( WR ='1' or RD='1') and sp(1)='0')
    else '0' when (sp(1)='1' or ( WR ='0' and RD='0' and RST ='0'));
    
    MemoryReadSignal<='1' when ((RETEn='1' and RETCounterValue='0') or (RTIEn='1' and RTICounterValue="01") or (INTEn='1' and INTCounterValue="01") ) else '0';
    
    ResumeSignal <='1' when  (CALLEn='1'  and falling_edge(clk)) or (RETEn='1' and RETCounterValue='1') or (RTIEn='1' and RTICounterValue="10") or (INTEn='1' and INTCounterValue="11") else '0';
    
    WR<='1' when (CALLEn='1' ) or (INTEn='1' and INTCounterValue="00") or (INTEn='1' and INTCounterValue="10") or WRIn ='1' else '0';
    
    RD<='1' when (RETEn='1' and RETCounterValue='0') or (RTIEn='1' and RTICounterValue="00") or (RTIEn='1' and RTICounterValue="01") or(RST='1') or (INTEn='1' and INTCounterValue="01") or RDIn='1' else '0';
    
    WriteSignal<=WR;
    ReadSignal<=RD;
    
    Address <= (others=>'0') when RST='1' and INTEn ='0' else X"00000002" when INTEn='1' and RST='0' else AddressIn;
    
    MemoryPC <= MEMOUT when (RETEn='1' and RETCounterValue='0') or (RST='1' ) or (INTEn ='1' and INTCounterValue="01") or (RTIEn ='1' and RTICounterValue="01") else (others=>'0');
    
    FlagsOut <= MEMOUT when (RTIEn='1' and RTICounterValue="00");
    

INTCounterProcess: process(clk,INTCounterReset,INTcounterEnable)
begin
    if(INTCounterReset ='1')then
        INTCounterValue<=(others=>'0');
    elsif rising_edge(clk) and INTCounterReset='0' then
        if INTcounterEnable ='1' then
            INTCounterValue <= std_logic_vector(unsigned(INTCounterValue)+1);
        end if;
    end if;
end process;

RTICounterProcess: process(clk,RTICounterReset,RTIcounterEnable)
begin
    if(RTICounterReset ='1')then
        RTICounterValue<=(others=>'0');
    elsif rising_edge(clk) and RTICounterReset='0' then
        if RTIcounterEnable ='1' then
            RTICounterValue <= std_logic_vector(unsigned(RTICounterValue)+1);
        end if;
    end if;
end process;

CALLCounterProcess: process(clk,CALLCounterReset,CALLcounterEnable)
begin
    if(CALLCounterReset ='1')then
        CALLCounterValue<='0';
    elsif rising_edge(clk) and CALLCounterReset='0' then
        if CALLcounterEnable ='1' then
            CALLCounterValue <= not CALLCounterValue;
        end if;
    end if;
end process;

RETCounterProcess: process(clk,RETCounterReset,RETcounterEnable)
begin
    if(RETCounterReset ='1')then
        RETCounterValue<='0';
    elsif rising_edge(clk) and RETCounterReset='0' then
        if RETcounterEnable ='1' then
            RETCounterValue <=not RETCounterValue;
        end if;
    end if;
end process;
end architecture ; -- arch