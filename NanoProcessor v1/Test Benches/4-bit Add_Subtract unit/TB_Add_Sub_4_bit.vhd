----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 07:31:06 PM
-- Design Name: 
-- Module Name: TB_Add_Sub_4_bit - Behavioral
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

entity TB_Add_Sub_4_bit is
--  Port ( );
end TB_Add_Sub_4_bit;

architecture Behavioral of TB_Add_Sub_4_bit is
component Add_Sub_4_bit
        Port(
            A_AS : in STD_LOGIC_VECTOR (3 DOWNTO 0);
            B_AS : in STD_LOGIC_VECTOR (3 DOWNTO 0);
            CTRL : in STD_LOGIC;
            S_AS : out STD_LOGIC_VECTOR(3 DOWNTO 0);
            Zero : out STD_LOGIC;
            OverFlow : out STD_LOGIC
        );
    end component;

    signal A_AS, B_AS, S_AS : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal CTRL, Zero, OverFlow : STD_LOGIC;

begin
uut: Add_Sub_4_bit
        port map (
            A_AS => A_AS,
            B_AS => B_AS,
            CTRL => CTRL,
            S_AS => S_AS,
            Zero => Zero,
            OverFlow => OverFlow
        );

    process
    begin
        
        -- Index-based test cases using 240618
        -- Binary: 111010101111101010 → grouped into 4 bits
        
        -- From index: 1010 + 1111
        -- 10 + 15 = 25 → overflow
        A_AS <= "1010"; B_AS <= "1111"; CTRL <= '0';
        wait for 10 ns;
        
        -- From index: 1010 - 1111
        -- 10 - 15 = -5 → negative (overflow possible depending on design)
        A_AS <= "1010"; B_AS <= "1111"; CTRL <= '1';
        wait for 10 ns;
        
        -- From index: 1010 + 1110
        -- 10 + 14 = 24 → overflow
        A_AS <= "1010"; B_AS <= "1110"; CTRL <= '0';
        wait for 10 ns;
        
        -- From index: 1010 - 1110
        -- 10 - 14 = -4
        A_AS <= "1010"; B_AS <= "1110"; CTRL <= '1';
        wait for 10 ns;
        
        --other basic combinations
        -- 3 + 2 = 5
        A_AS <= "0011"; B_AS <= "0010"; CTRL <= '0';
        wait for 10 ns;

        -- 3 - 2 = 1
        A_AS <= "0011"; B_AS <= "0010"; CTRL <= '1';
        wait for 10 ns;

        -- 2 - 5 = -3
        A_AS <= "0010"; B_AS <= "0101"; CTRL <= '1';
        wait for 10 ns;

        -- 7 + 1 = overflow
        A_AS <= "0111"; B_AS <= "0001"; CTRL <= '0';
        wait for 10 ns;
        
        -- 0 result test
        A_AS <= "0101"; B_AS <= "0101"; CTRL <= '1';
        wait for 10 ns;

        wait;

    end process;

end Behavioral;
