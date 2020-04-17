
Library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity full_adder is port(a,b,c:in STD_LOGIC; sum,carry:out STD_LOGIC); 
end full_adder;
  
architecture data of full_adder is
begin
   sum<= a xor b xor c; 
   carry <= ((a and b) or (b and c) or (a and c)); 
end data;