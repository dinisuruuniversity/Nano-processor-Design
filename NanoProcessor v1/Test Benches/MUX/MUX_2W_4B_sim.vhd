----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 06:00:00 PM
-- Design Name: 
-- Module Name: MUX_2W_4B_sim - Behavioral
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

entity MUX_2W_4B_sim is
--  Port ( );
end MUX_2W_4B_sim;

architecture Behavioral of MUX_2W_4B_sim is
COMPONENT MUX_2W_4B
port(
    input1 : in STD_LOGIC_VECTOR(3 downto 0);
    input2 : in STD_LOGIC_VECTOR(3 downto 0);
    slt : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(3 downto 0)
);
END COMPONENT;

SIGNAL in1 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL in2 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL sel : STD_LOGIC;
SIGNAL outpt : STD_LOGIC_VECTOR(3 downto 0);

begin
UUT : MUX_2W_4B PORT MAP(
    input1 => in1,
    input2 => in2,
    slt => sel,
    output => outpt
);

process
begin
-- Index No : 240604V;
-- Binary representation : 11 1010 1011 1101 1100
    sel <= '0';
    in1 <= "1100";
    in2 <= "1101";
    WAIT FOR 100ns;
    
    sel <= '1';
    WAIT FOR 100ns;
    
    in1 <= "1011";
    WAIT FOR 100ns;
    
    sel <= '1';
    WAIT FOR 100ns;
    
    in2 <= "1010";
    WAIT FOR 100ns;
    
    sel <= '0';
    WAIT;
end process;
end Behavioral;
