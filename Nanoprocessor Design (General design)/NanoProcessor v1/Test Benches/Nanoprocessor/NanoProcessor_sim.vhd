library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NanoProcessor_sim is
end NanoProcessor_sim;

architecture Behavioral of NanoProcessor_sim is
    component NanoProcessor
        Port (
            Clk   : in  STD_LOGIC;
            Reset : in  STD_LOGIC;
            LED   : out STD_LOGIC_VECTOR(3 downto 0);
            seg   : out STD_LOGIC_VECTOR(6 downto 0);
            an    : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal Clk   : STD_LOGIC := '0';
    signal Reset : STD_LOGIC := '0';
    signal LED   : STD_LOGIC_VECTOR(3 downto 0);
    signal seg   : STD_LOGIC_VECTOR(6 downto 0);
    signal an    : STD_LOGIC_VECTOR(3 downto 0);

    constant clk_period : time := 10 ns;

begin
    UUT: NanoProcessor
        port map (
            Clk   => Clk,
            Reset => Reset,
            LED   => LED,
            seg   => seg,
            an    => an
        );
        
    clk_process : process
    begin
        while true loop
            Clk <= '0';
            wait for clk_period / 2;
            Clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_process : process
    begin
        Reset <= '1';
        wait for 50 ns;

        Reset <= '0';

        wait for 5000 ns;

        Reset <= '1';
        wait for 50 ns;
        Reset <= '0';

        wait for 5000 ns;

        wait;
    end process;

end Behavioral;