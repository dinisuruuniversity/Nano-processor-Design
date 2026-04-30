----------------------------------------------------------------------------------
-- Module Name:  Mul_4bit - Behavioral
-- Description:  4-bit x 4-bit unsigned combinational multiplier.
--               Produces the lower 4 bits of the 8-bit product.
--               Upper 4 bits are also exposed for potential future use.
--
--  How it works (shift-and-add):
--    Product = A*B[0]*1 + A*B[1]*2 + A*B[2]*4 + A*B[3]*8
--    Only the lower 4 bits are returned as the result bus
--    since the NanoProcessor data bus is 4-bit wide.
--
--  Examples:
--    2 x 3 = 6    → Product_L = "0110"  (fits in 4 bits)
--    3 x 3 = 9    → Product_L = "1001"  (fits in 4 bits)
--    4 x 4 = 16   → Product_L = "0000", Product_H = "0001" (overflow!)
--
-- Dependencies:
--   Packages/BusDefinitions.vhd  (DataBus)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Mul_4bit is
    Port (
        A         : in  DataBus;    -- 4-bit multiplicand
        B         : in  DataBus;    -- 4-bit multiplier
        Product_L : out DataBus;    -- Lower 4 bits of result (written to register)
        Product_H : out DataBus     -- Upper 4 bits of result (overflow indicator)
    );
end Mul_4bit;

architecture Behavioral of Mul_4bit is

    -- 8-bit internal product to hold full result before truncation
    signal full_product : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Shift-and-add multiplication using numeric_std
    -- unsigned(A) * unsigned(B) produces an 8-bit result
    full_product <= STD_LOGIC_VECTOR(unsigned(A) * unsigned(B));

    -- Lower nibble → written to destination register
    Product_L <= full_product(3 downto 0);

    -- Upper nibble → available for overflow detection
    Product_H <= full_product(7 downto 4);

end Behavioral;
