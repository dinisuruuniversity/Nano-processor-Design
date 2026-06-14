----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 07:18:21 PM
-- Design Name: 
-- Module Name: TB_RCA_4 - Behavioral
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

entity TB_RCA_4 is
--  Port ( );
end TB_RCA_4;

architecture Behavioral of TB_RCA_4 is
  -- Component declaration
    component RCA_4
        Port (
            A : in STD_LOGIC_VECTOR (3 downto 0);
            B : in STD_LOGIC_VECTOR (3 downto 0);
            C_in : in STD_LOGIC;
            S : out STD_LOGIC_VECTOR (3 downto 0);
            C_out : out STD_LOGIC
        );
    end component;

    -- Signals
    signal A, B, S : STD_LOGIC_VECTOR(3 downto 0);
    signal C_in, C_out : STD_LOGIC;

begin
-- Instantiate UUT
    uut: RCA_4
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
        A <= "0000"; B <= "0000"; C_in <= '0';
        wait for 10 ns;
        
        -- Test 2: 1 + 1 = 2
        A <= "0001"; B <= "0001"; C_in <= '0';
        wait for 10 ns;

        -- Test 3: 3 + 2 = 5
        A <= "0011"; B <= "0010"; C_in <= '0';
        wait for 10 ns;

        -- Test 4: 7 + 1 = 8
        A <= "0111"; B <= "0001"; C_in <= '0';
        wait for 10 ns;

        -- Test 5: 15 + 1 = 16 (overflow)
        A <= "1111"; B <= "0001"; C_in <= '0';
        wait for 10 ns;

        -- Test 6: with carry-in (3 + 2 + 1 = 6)
        A <= "0011"; B <= "0010"; C_in <= '1';
        wait for 10 ns;

        wait;

    end process;


end Behavioral;
