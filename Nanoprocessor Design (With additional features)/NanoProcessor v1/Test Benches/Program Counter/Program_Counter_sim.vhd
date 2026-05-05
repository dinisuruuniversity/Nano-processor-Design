library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Program_Counter_sim is
end Program_Counter_sim;

architecture Behavioral of Program_Counter_sim is

component Program_Counter is
    Port (
        Nxt  : in  ProgramCounter; 
        Res  : in  STD_LOGIC;
        Clk  : in  STD_LOGIC;
        Curr : out ProgramCounter
    );
end component;

signal nxt  : ProgramCounter := (others => '0');
signal res  : STD_LOGIC := '0';
signal clk  : STD_LOGIC := '0';
signal curr : ProgramCounter;

begin
    UUT: Program_Counter
        port map (
            Nxt  => nxt,
            Res  => res,
            Clk  => clk,
            Curr => curr
        );
        
process
begin
    clk <= '0';
    wait for 100ns;
    clk <= '1';
    wait for 100ns;
end process;

process
begin
    
    res <= '1';
    wait for 100ns;
    
    wait for 50ns;
    res <= '0';

    for i in 0 to 4 loop
        nxt <= std_logic_vector(to_unsigned(i, 3));
        wait for 100ns; 
    end loop;

    res <= '1';
    wait for 100ns;

    nxt <= "111"; 
    wait for 100ns;
    res <= '0';
    wait for 100ns;
    nxt <= "110";
    wait for 100ns;
    
    res <= '0';
end process;

end Behavioral;
