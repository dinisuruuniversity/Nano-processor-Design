----------------------------------------------------------------------------------
-- Package Name: BusDefinitions
-- Description:  Shared type definitions used across the CPU design.
--               Include this package with:  use work.BusDefinitions.all;
--
-- Types defined:
--   DataBus        : 4-bit data word (matches register width)
--   RegisterSelect : 3-bit address to select one of 8 registers (R0-R7)
--   RegisterFile   : Array of 8 x 4-bit values representing all register outputs
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package BusDefinitions is

    -- 4-bit data bus (register width)
    subtype DataBus is STD_LOGIC_VECTOR(3 downto 0);

    -- 3-bit register address (selects R0 to R7)
    subtype RegisterSelect is STD_LOGIC_VECTOR(2 downto 0);

    -- Array of all 8 register outputs (index 0 = R0, index 7 = R7)
    type RegisterFile is array (0 to 7) of STD_LOGIC_VECTOR(3 downto 0);

end package BusDefinitions;
