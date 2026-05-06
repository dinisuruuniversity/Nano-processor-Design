library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Slow_Clk_TB is
end Slow_Clk_TB;

architecture Behavioral of Slow_Clk_TB is

    -- Component under test (Updated to include Reset)
    component Slow_Clk is
        Port (
            Clk_in  : in  STD_LOGIC;
            Reset   : in  STD_LOGIC; -- Added Reset port
            Clk_out : out STD_LOGIC
        );
    end component;

    -- Testbench signals
    signal tb_Clk_in  : STD_LOGIC := '0';
    signal tb_Reset   : STD_LOGIC := '0'; -- Added signal for Reset
    signal tb_Clk_out : STD_LOGIC;

    -- Clock period (10 ns = 100 MHz)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: Slow_Clk
        port map (
            Clk_in  => tb_Clk_in,
            Reset   => tb_Reset,   -- Mapped the Reset signal
            Clk_out => tb_Clk_out
        );

    -- Generate input clock
    clk_process: process
    begin
        -- Using a 'loop' without a 'now' constraint is more common for 
        -- infinite clocks, but keeping your structure:
        while now < 2000 ns loop -- Increased time to see more cycles
            tb_Clk_in <= '0';
            wait for CLK_PERIOD / 2;
            tb_Clk_in <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process to handle the Reset pulse
    stim_proc: process
    begin
        -- Hold reset high for a short duration to initialize the counter
        tb_Reset <= '1';
        wait for 20 ns;
        tb_Reset <= '0';
        wait;
    end process;

end Behavioral;