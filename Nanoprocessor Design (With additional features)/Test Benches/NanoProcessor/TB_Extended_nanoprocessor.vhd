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
use work.BusDefinitions.all;

entity NanoProcessor_TB is
-- No ports in testbench
end NanoProcessor_TB;

architecture Behavioral of NanoProcessor_TB is

    -- Component declaration
    component NanoProcessor
        Port (
            Clk   : in  STD_LOGIC;
            Reset : in  STD_LOGIC;
            LED   : out STD_LOGIC_VECTOR(15 downto 0);
            seg   : out STD_LOGIC_VECTOR(6 downto 0);
            an    : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Input signals
    signal tb_Clk   : STD_LOGIC := '0';
    signal tb_Reset : STD_LOGIC := '0';

    -- Output signals (raw from UUT)
    signal tb_LED   : STD_LOGIC_VECTOR(15 downto 0);
    signal tb_seg   : STD_LOGIC_VECTOR(6 downto 0);
    signal tb_an    : STD_LOGIC_VECTOR(3 downto 0);

    -- Readable signals extracted from LED bus
    signal tb_R7          : STD_LOGIC_VECTOR(3 downto 0);  -- LED(3  downto 0)
    signal tb_Equal       : STD_LOGIC;                     -- LED(11)
    signal tb_LessThan    : STD_LOGIC;                     -- LED(12)
    signal tb_GreaterThan : STD_LOGIC;                     -- LED(13)
    signal tb_Zero        : STD_LOGIC;                     -- LED(14)
    signal tb_Overflow    : STD_LOGIC;                     -- LED(15)

    -- Clock period constant
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test
    UUT: NanoProcessor
        port map (
            Clk   => tb_Clk,
            Reset => tb_Reset,
            LED   => tb_LED,
            seg   => tb_seg,
            an    => tb_an
        );

    -----------------------------------------------------------------------
    -- Concurrent Signal Assignments
    -- Extract individual flags from the LED output bus
    -----------------------------------------------------------------------
    tb_R7          <= tb_LED(3  downto 0);
    tb_Equal       <= tb_LED(11);
    tb_LessThan    <= tb_LED(12);
    tb_GreaterThan <= tb_LED(13);
    tb_Zero        <= tb_LED(14);
    tb_Overflow    <= tb_LED(15);

    -----------------------------------------------------------------------
    
    -----------------------------------------------------------------------
    Clock_process: process
    begin
        tb_Clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_Clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -----------------------------------------------------------------------
    -- Stimulus Process
    -----------------------------------------------------------------------
    Stimulus_process: process
    begin
        -- Apply reset
        tb_Reset <= '1';
        wait for 20 ns;

        
        tb_Reset <= '0';

       
        wait for 10000 ns;

       
        tb_Reset <= '1';
        wait for 20 ns;
        tb_Reset <= '0';

        
        wait for 10000 ns;

        -- End simulation
        wait;
    end process;

end Behavioral;
