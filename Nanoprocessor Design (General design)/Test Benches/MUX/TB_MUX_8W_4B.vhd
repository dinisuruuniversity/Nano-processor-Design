----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 06:19:10 PM
-- Design Name: 
-- Module Name: MUX_8W_4B_sim - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX_8W_4B_sim is
--  Port ( );
end MUX_8W_4B_sim;

architecture Behavioral of MUX_8W_4B_sim is

COMPONENT MUX_8W_4B
PORT(
    input1  : in STD_LOGIC_VECTOR(3 downto 0);
    input2  : in STD_LOGIC_VECTOR(3 downto 0);
    input3  : in STD_LOGIC_VECTOR(3 downto 0);
    input4  : in STD_LOGIC_VECTOR(3 downto 0);
    input5  : in STD_LOGIC_VECTOR(3 downto 0);
    input6  : in STD_LOGIC_VECTOR(3 downto 0);
    input7  : in STD_LOGIC_VECTOR(3 downto 0);
    input8  : in STD_LOGIC_VECTOR(3 downto 0);
    slt     : in STD_LOGIC_VECTOR(2 downto 0);
    output  : out STD_LOGIC_VECTOR(3 downto 0)
);
END COMPONENT;

SIGNAL in1 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in2 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in3 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in4 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in5 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in6 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in7 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in8 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL outpt : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL sel : STD_LOGIC_VECTOR(2 downto 0);

begin
UUT : MUX_8W_4B PORT MAP(
    input1 => in1,
    input2 => in2,
    input3 => in3,
    input4 => in4,
    input5 => in5,
    input6 => in6,
    input7 => in7,
    input8 => in8,
    output => outpt,
    slt => sel
);

process 
begin

-- Index No : 240604V;
-- Binary representation : 11 1010 1011 1101 1100

-- Index No : 240593H;
-- Binary Representation : 11 1010 1011 1101 0001

    sel <= "000";
    in1 <= "1100";
    in2 <= "1101";
    in3 <= "1011";
    in4 <= "1010";
    in5 <= "0001";
    in6 <= "1101";
    in7 <= "1011";
    in8 <= "1010";
    WAIT FOR 100ns;
    
    sel <= "001";
    WAIT FOR 100ns;
    
    sel <= "001";
    WAIT FOR 100ns;
        
    sel <= "010";
    WAIT FOR 100ns;
    
    sel <= "011";
    WAIT FOR 100ns;
    
    sel <= "100";
    WAIT FOR 100ns;
        
    sel <= "101";
    WAIT FOR 100ns;
    
    sel <= "110";
    WAIT FOR 100ns;
    
    sel <= "111";
    WAIT;
end process;
end Behavioral;
