----------------------------------------------------------------------------------
-- Module Name: Reg - Behavioral
-- Description: 4-bit register with clock enable and asynchronous reset.
--
-- Ports:
--   D   : 4-bit data input
--   Res : Asynchronous active-high reset  (clears Q to "0000" immediately)
--   En  : Clock enable  (Q updates on rising clock edge only when En = '1')
--   Clk : Clock input
--   Q   : 4-bit registered output
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg is
    Port (
        D   : in  STD_LOGIC_VECTOR (3 downto 0);
        Res : in  STD_LOGIC;
        En  : in  STD_LOGIC;
        Clk : in  STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Reg;

architecture Behavioral of Reg is
begin

    process (Clk, Res) begin
        if Res = '1' then
            Q <= "0000";                -- Asynchronous reset: clear immediately
        elsif rising_edge(Clk) then
            if En = '1' then
                Q <= D;                 -- Capture input on rising edge when enabled
            end if;
        end if;
    end process;

end Behavioral;
