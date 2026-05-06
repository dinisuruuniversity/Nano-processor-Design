----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 09:02:14 PM
-- Design Name: 
-- Module Name: Slow_Clk - Behavioral
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

entity Slow_Clk is
    Port ( Clk_in  : in STD_LOGIC;
           Reset   : in STD_LOGIC; -- Add this Port
           Clk_out : out STD_LOGIC);
end Slow_Clk;

architecture Behavioral of Slow_Clk is
    signal count      : integer   := 1;
    signal clk_status : std_logic := '0';

begin

    -- Always drive Clk_out from the registered status flag so the
    -- output is never 'U' before the first 50,000,000-cycle period.
    Clk_out <= clk_status;

process (Clk_in, Reset) begin
        if Reset = '1' then
            count <= 1;
            clk_status <= '0';
        elsif rising_edge(Clk_in) then
            if count = 50000000 then
                clk_status <= not clk_status;
                count <= 1;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
end Behavioral;
