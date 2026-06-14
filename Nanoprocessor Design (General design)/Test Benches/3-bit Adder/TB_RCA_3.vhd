----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 05:25:14 PM
-- Design Name: 
-- Module Name: TB_RCA_3 - Behavioral
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

entity TB_RCA_3 is
--  Port ( );
end TB_RCA_3;

architecture Behavioral of TB_RCA_3 is
component RCA_3
        Port ( 
            A : in STD_LOGIC_VECTOR(2 DOWNTO 0);
            B : in STD_LOGIC_VECTOR(2 DOWNTO 0);
            C_in : in STD_LOGIC;
            S : out STD_LOGIC_VECTOR(2 DOWNTO 0);
            C_out : out STD_LOGIC
        );
    end component;

-- Signals
signal A, B, S : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal C_in, C_out : STD_LOGIC;

begin
 -- Instantiate UUT
    uut: RCA_3
        port map (
            A => A,
            B => B,
            C_in => C_in,
            S => S,
            C_out => C_out
        );

    -- Stimulus process
    process
    begin

        -- Test 1: 0 + 0 = 0
        A <= "000"; B <= "000"; C_in <= '0';
        wait for 10 ns;

        -- Test 2: 1 + 1 = 2
        A <= "001"; B <= "001"; C_in <= '0';
        wait for 10 ns;
        
        -- Test 3: 3 + 2 = 5
        A <= "011"; B <= "010"; C_in <= '0';
        wait for 10 ns;

        -- Test 4: 7 + 1 = 8 (overflow)
        A <= "111"; B <= "001"; C_in <= '0';
        wait for 10 ns;

        -- Test 5: 5 + 3 = 8 (overflow)
        A <= "101"; B <= "011"; C_in <= '0';
        wait for 10 ns;

        -- Test 6: with carry input (3 + 2 + 1 = 6)
        A <= "011"; B <= "010"; C_in <= '1';
        wait for 10 ns;

        wait;

    end process;

end Behavioral;
