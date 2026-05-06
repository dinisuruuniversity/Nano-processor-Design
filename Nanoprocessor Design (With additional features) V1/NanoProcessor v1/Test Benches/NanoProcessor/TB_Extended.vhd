----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2026 06:43:39 AM
-- Design Name: 
-- Module Name: TB_Extended - Behavioral
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

entity TB_Extended is
--  Port ( );
end TB_Extended;

architecture Behavioral of TB_Extended is
component NanoProcessor
        Port (
            Clk   : in  STD_LOGIC;
            Reset : in  STD_LOGIC;
            LED   : out STD_LOGIC_VECTOR(15 downto 0);
            seg   : out STD_LOGIC_VECTOR(6 downto 0);
            an    : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal clk_tb   : STD_LOGIC := '0';
    signal reset_tb : STD_LOGIC := '0';
    signal led_tb   : STD_LOGIC_VECTOR(15 downto 0);
    signal seg_tb   : STD_LOGIC_VECTOR(6 downto 0);
    signal an_tb    : STD_LOGIC_VECTOR(3 downto 0);

    constant clk_period : time := 10 ns; -- 100 MHz

begin

    UUT: NanoProcessor
        port map (
            Clk   => clk_tb,
            Reset => reset_tb,
            LED   => led_tb,
            seg   => seg_tb,
            an    => an_tb
        );

    -- Generate 100MHz Clock
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus
    stim_proc: process
    begin		
        -- Global Reset
        reset_tb <= '1';
        wait for 100 ns;
        reset_tb <= '0';
        
        wait for 2 sec; 
        wait;
    end process;

end Behavioral;

