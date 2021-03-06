LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY Reg IS
GENERIC (n:integer:=16);
	PORT (
		input		:	IN	std_logic_vector(n-1 downto 0);
		en,rst,clk	:	IN	std_logic;
		output		:	OUT	std_logic_vector(n-1 downto 0)
	);
END ENTITY;

ARCHITECTURE RegArch OF Reg IS
BEGIN

	PROCESS (rst,clk) 
	BEGIN
		IF (rst='1') THEN
			output <= (others =>'0');
		ELSIF (rising_edge(clk)) THEN 
		
			IF (en='1') THEN
				output <= input;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
architecture RegFalling of Reg is
	BEGIN

	PROCESS (rst,clk) 
	BEGIN
		IF (rst='1') THEN
			output <= (others =>'0');
		ELSIF (falling_edge(clk)) THEN 
		
			IF (en='1') THEN
				output <= input;
			END IF;
		END IF;
	END PROCESS;

	end architecture;