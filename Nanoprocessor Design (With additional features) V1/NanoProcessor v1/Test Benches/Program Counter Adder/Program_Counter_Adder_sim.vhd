----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 03:42:38 PM
-- Design Name: 
-- Module Name: Program_Counter_Adder_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter_Adder_sim is
--  Port ( );
end Program_Counter_Adder_sim;

architecture Behavioral of Program_Counter_Adder_sim is

COMPONENT Program_Counter_Adder
port(
    currAddress : in ProgramCounter;
    nxtAddress  : out ProgramCounter
);
END COMPONENT;

SIGNAL curr : ProgramCounter := (others => '0');
SIGNAL nxt : ProgramCounter;

begin

UUT : Program_Counter_Adder PORT MAP(
    currAddress => curr,
    nxtAddress => nxt 
);

process
begin
    curr <= "000";
    WAIT FOR 100ns;
    
    curr <= "001";
    WAIT FOR 100ns;
    
    curr <= "010";
    WAIT FOR 100ns;
    
    curr <= "011";
    WAIT FOR 100ns;
    
    curr <= "100";
    WAIT FOR 100ns;
    
    curr <= "101";
    WAIT FOR 100ns;
    
    curr <= "110";
    WAIT FOR 100ns;
    
    curr <= "111";
    WAIT;
    
end process;
end Behavioral;
