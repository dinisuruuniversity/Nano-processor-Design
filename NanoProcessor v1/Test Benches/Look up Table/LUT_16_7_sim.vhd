library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LUT_16_7_TB is
end LUT_16_7_TB;

architecture Behavioral of LUT_16_7_TB is
component LUT_16_7 is
Port (
    address : in  STD_LOGIC_VECTOR(3 downto 0);
    data    : out STD_LOGIC_VECTOR(6 downto 0)
);
end component;

signal address : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal data    : STD_LOGIC_VECTOR(6 downto 0);

begin
UUT: LUT_16_7
    port map (
        address => address,
        data    => data
);

process
begin
    -- Index No : 240604V;
    -- Binary Representation : 11 1010 1011 1101 1100
    
    -- Index No : 240593H;
    -- Binary Representation : 11 1010 1011 1101 0001
    
    address <= "1100";
    WAIT FOR 100ns;
    address <= "1101";
    WAIT FOR 100ns;
    address <= "1011";
    WAIT FOR 100ns;
    address <= "1010";
    WAIT FOR 100ns;
    
    address <= "0001";
    WAIT FOR 100ns;
    address <= "1101";
    WAIT FOR 100ns;
    address <= "1011";
    WAIT FOR 100ns;
    address <= "1010";
    WAIT;
    
end process; 
end Behavioral;