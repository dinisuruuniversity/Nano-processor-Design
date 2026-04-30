----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 05:35:41 PM
-- Design Name: 
-- Module Name: MUX_2W_3B_sim - Behavioral
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

entity MUX_2W_3B_sim is
-- PORT();
end MUX_2W_3B_sim;

architecture Behavioral of MUX_2W_3B_sim is

COMPONENT MUX_2W_3B
PORT(
    input1  : in STD_LOGIC_VECTOR(2 downto 0);
    input2  : in STD_LOGIC_VECTOR(2 downto 0);
    slt     : in STD_LOGIC;
    output  : out STD_LOGIC_VECTOR(2 downto 0)
);
END COMPONENT;

SIGNAL in1 : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL in2 : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL outpt : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL sel : STD_LOGIC;

begin

UUT : MUX_2W_3B PORT MAP(
    input1 => in1,
    input2 => in2,
    output => outpt,
    slt => sel
);

process
begin

-- Index No : 240604V;
-- Binary representation : 111 010 101 111 011 100
    sel <= '0';
    in1 <= "100";
    in2 <= "011";
    
    WAIT FOR 100ns;
    
    sel <= '1';
    WAIT FOR 100ns;
    
    in1 <= "111";
    WAIT FOR 100ns;
    
    sel <= '0';
    WAIT FOR 100ns;
    
    in1 <= "101";
    WAIT FOR 100ns;
    
    sel <= '1';
    WAIT FOR 100ns;
    
    in1 <= "010";
    WAIT FOR 100ns;
    
    sel <= '0';
    WAIT;
end process;
end Behavioral;
