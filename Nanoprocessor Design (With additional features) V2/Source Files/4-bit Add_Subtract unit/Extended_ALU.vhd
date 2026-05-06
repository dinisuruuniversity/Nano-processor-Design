----------------------------------------------------------------------------------
-- Module Name:  Extended_ALU - Behavioral
-- Description:  Unified 4-bit ALU supporting all 6 compute operations of the
--               13-bit NanoProcessor instruction set.
--
--  Op (3-bit) maps directly to the instruction opcode:
--    "000" = ADD  : Result = A + B
--    "001" = SUB  : Result = A - B
--    "010" = NEG  : Result = 0 - B  (A is ignored; B holds the register value)
--    "011" = MUL  : Result = A * B  (lower 4 bits of 8-bit product)
--    "100" = AND  : Result = A AND B
--    "101" = OR   : Result = A OR B
--    others       : Result = "0000"
--
--  Zero flag    : '1' when Result = "0000"
--  Overflow flag: '1' when ADD/SUB carry-out occurs (upper bit of 5-bit result)
--               : '1' when MUL product exceeds 4 bits (upper nibble non-zero)
--
-- Dependencies:
--   Packages/BusDefinitions.vhd
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Extended_ALU is
    Port (
        A        : in  DataBus;                      -- First operand  (Rd)
        B        : in  DataBus;                      -- Second operand (Rs)
        Op       : in  STD_LOGIC_VECTOR(3 downto 0); -- Operation select (= opcode)
        Result   : out DataBus;                      -- 4-bit result
        Zero     : out STD_LOGIC;                    -- '1' when Result = 0
        Overflow : out STD_LOGIC                     -- Carry / product overflow
    );
end Extended_ALU;

architecture Behavioral of Extended_ALU is

    signal result_int  : STD_LOGIC_VECTOR(4 downto 0); -- 5-bit for carry detection
    signal product_int : STD_LOGIC_VECTOR(7 downto 0); -- 8-bit for MUL
    signal result_4b   : DataBus;

begin

    -- -------------------------------------------------------------------------
    -- Combinational compute block
    -- Sensitivity list contains ONLY true inputs (A, B, Op).
    -- product_int is driven by this process so must NOT be in the list.
    -- A local variable (prod_v) is used so the MUL result is available
    -- immediately within the same process evaluation (no delta-cycle lag).
    -- -------------------------------------------------------------------------
    process(A, B, Op)
        variable prod_v : STD_LOGIC_VECTOR(7 downto 0);  -- scratch variable for MUL
    begin
        result_int  <= (others => '0');
        product_int <= (others => '0');
        prod_v      := (others => '0');

        case Op is
            when "0000" =>  -- ADD: A + B
                result_int <= std_logic_vector(
                    ('0' & unsigned(A)) + ('0' & unsigned(B)));

            when "0001" =>  -- SUB: A - B
                result_int <= std_logic_vector(
                    ('0' & unsigned(A)) - ('0' & unsigned(B)));

            when "0010" =>  -- NEG: 0 - B
            result_int <= std_logic_vector(
            ('0' & unsigned(std_logic_vector'("0000"))) - ('0' & unsigned(B))
             );

            when "0011" =>  -- MUL: A x B  (full 8-bit product, lower nibble returned)
                prod_v      := std_logic_vector(unsigned(A) * unsigned(B));
                product_int <= prod_v;               -- full product for overflow check
                result_int  <= '0' & prod_v(3 downto 0); -- lower 4 bits as result

            when "0100" =>  -- AND: bitwise A AND B
                result_int <= '0' & (A and B);

            when "0101" =>  -- OR: bitwise A OR B
                result_int <= '0' & (A or B);
                
            when "1000" =>  -- EQUAL
                if (unsigned(A) = unsigned(B)) then
                    result_int <= "00001";
                else
                    result_int <= "00000";
                end if;
            
            when "1001" =>  -- GREATER THAN
                if (unsigned(A) > unsigned(B)) then
                    result_int <= "00001";
                else
                    result_int <= "00000";
                end if;
                
            when "1010" =>  -- LESS THAN
                if (unsigned(A) < unsigned(B)) then
                    result_int <= "00001";
                else
                    result_int <= "00000";
                end if;
                
            when others =>
                result_int <= (others => '0');
        end case;
    end process;

    -- Lower 4 bits are the actual result
    result_4b <= result_int(3 downto 0);
    Result    <= result_4b;

    -- Zero flag
    Zero <= '1' when result_4b = "0000" else '0';

    -- Overflow flag:
    --   For ADD/SUB: bit[4] of 5-bit result (carry out)
    --   For MUL: upper nibble of product non-zero
    --   For AND/OR/NEG: always '0'
    Overflow <= 
        result_int(4) when (Op = "0000" or  -- ADD
                            Op = "0001" or  -- SUB
                            Op = "0010")    -- NEG
        else
        '1' when (Op = "0011" and product_int(7 downto 4) /= "0000")  -- MUL overflow
        else
        '0';

end Behavioral;
