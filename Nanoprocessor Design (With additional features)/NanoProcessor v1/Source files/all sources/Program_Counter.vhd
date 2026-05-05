library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.ProgramCounter;

entity Program_Counter is
    Port ( 
        Nxt         : in  ProgramCounter;  -- The 3-bit address coming from the MUX
        Res         : in  STD_LOGIC;       -- Reset
        Clk         : in  STD_LOGIC;       -- Slow clock
        Curr        : out ProgramCounter   -- The current 3-bit address sent to ROM
    );
end Program_Counter;

architecture Structural of Program_Counter is
    component D_FF
        port(
            D    : in  STD_LOGIC;
            Res  : in  STD_LOGIC;
            Clk  : in  STD_LOGIC;
            Q    : out STD_LOGIC;
            Qbar : out STD_LOGIC
        );
    end component;

begin
    D_FF0: D_FF port map (
        D    => Nxt(0), 
        Res  => Res, 
        Clk  => Clk, 
        Q    => Curr(0), 
        Qbar => open
    );

    D_FF1: D_FF port map (
        D    => Nxt(1), 
        Res  => Res, 
        Clk  => Clk, 
        Q    => Curr(1), 
        Qbar => open
    );
    D_FF2: D_FF port map (
        D    => Nxt(2), 
        Res  => Res, 
        Clk  => Clk, 
        Q    => Curr(2), 
        Qbar => open
    );

end Structural;
