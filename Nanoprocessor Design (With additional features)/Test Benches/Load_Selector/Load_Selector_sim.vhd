----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 02:41:48 PM
-- Design Name: 
-- Module Name: Load_Selector_sim - Behavioral
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

entity Load_Selector_sim is
--  Port ( );
end Load_Selector_sim;

architecture Behavioral of Load_Selector_sim is

COMPONENT Load_Selector
PORT (
    registerValue   : in STD_LOGIC_VECTOR(3 downto 0);
    immediateValue  : in STD_LOGIC_VECTOR(3 downto 0);
    lSlt            : in STD_LOGIC;
    outValue        : out STD_LOGIC_VECTOR(3 downto 0)
);
END COMPONENT;

SIGNAL rV  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
SIGNAL iV  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
SIGNAL sel : STD_LOGIC := '0';
SIGNAL outV  : STD_LOGIC_VECTOR(3 downto 0);

begin

UUT : Load_Selector PORT MAP(
    registerValue => rV,
    immediateValue => iV,
    lSlt => sel,
    outValue => outV
);

process
begin

    -- Index No : 240604V
    -- Binary representation : 11 1010 1011 1101 1100

    iV <= "1100";
    rV <= "1101";
    sel <= '0'; -- iV
    WAIT FOR 100ns;
    
    sel <= '1'; --rV
    WAIT FOR 100ns;
    
    iV <= "1011";
    rV <= "1010";
    sel <= '0'; --iV
    WAIT FOR 100ns;
    
    sel <= '1'; -- rV
    WAIT ;
    
end process;
end Behavioral;
