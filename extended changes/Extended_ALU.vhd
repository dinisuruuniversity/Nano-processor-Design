----------------------------------------------------------------------------------
-- Module Name:  Extended_ALU - Structural
-- Description:  Unified 4-bit ALU supporting all compute operations.
--
--  Op (4-bit) maps directly to the instruction opcode:
--    "0000" = ADD : Result = A + B
--    "0001" = SUB : Result = A - B
--    "0010" = NEG : Result = 0 - B
--    "0011" = MUL : Result = A * B (lower 4 bits)
--    "0100" = AND : Result = A AND B
--    "0101" = OR  : Result = A OR B
--    "1000" = EQ  : Equal_Flag='1' if A = B, Result="0001" or "0000"
--    "1001" = GT  : GreaterThan_Flag='1' if A > B, Result="0001" or "0000"
--    "1010" = LT  : LessThan_Flag='1' if A < B, Result="0001" or "0000"
--    others       : Result = "0000"
--
--  Zero flag     : '1' when Result = "0000"
--  Overflow flag : '1' when ADD/SUB/NEG carry-out occurs
--                : '1' when MUL product exceeds 4 bits
--
-- Dependencies:
--   Packages/BusDefinitions.vhd
--   Add_Sub_4_bit.vhd
--   Comparator_4_bit.vhd
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Extended_ALU is
    Port (
        A                : in  DataBus;                       -- First operand  (Rd)
        B                : in  DataBus;                       -- Second operand (Rs)
        Op               : in  STD_LOGIC_VECTOR(3 downto 0); -- 4-bit opcode
        Result           : out DataBus;                       -- 4-bit result
        Zero             : out STD_LOGIC;                     -- '1' when Result = 0
        Overflow         : out STD_LOGIC;                     -- Carry/MUL overflow
        Equal_Flag       : out STD_LOGIC;                     -- '1' when A = B
        LessThan_Flag    : out STD_LOGIC;                     -- '1' when A < B
        GreaterThan_Flag : out STD_LOGIC                      -- '1' when A > B
    );
end Extended_ALU;

architecture Structural of Extended_ALU is

    -----------------------------------------------------------------------
    -- Component Declarations
    -----------------------------------------------------------------------
    component Add_Sub_4_bit is
        Port (
            A_AS     : in  STD_LOGIC_VECTOR(3 downto 0);
            B_AS     : in  STD_LOGIC_VECTOR(3 downto 0);
            CTRL     : in  STD_LOGIC;
            S_AS     : out STD_LOGIC_VECTOR(3 downto 0);
            Zero     : out STD_LOGIC;
            OverFlow : out STD_LOGIC
        );
    end component;

    component Comparator_4_bit is
        Port (
            Input_A          : in  DataBus;
            Input_B          : in  DataBus;
            Equal_Flag       : out STD_LOGIC;
            LessThan_Flag    : out STD_LOGIC;
            GreaterThan_Flag : out STD_LOGIC
        );
    end component;

    -----------------------------------------------------------------------
    -- Add_Sub Internal Signals
    -----------------------------------------------------------------------
    signal as_A        : STD_LOGIC_VECTOR(3 downto 0);
    signal as_B        : STD_LOGIC_VECTOR(3 downto 0);
    signal as_CTRL     : STD_LOGIC;
    signal as_result   : STD_LOGIC_VECTOR(3 downto 0);
    signal as_zero     : STD_LOGIC;
    signal as_overflow : STD_LOGIC;

    -----------------------------------------------------------------------
    -- Comparator Internal Signals
    -----------------------------------------------------------------------
    signal comp_equal   : STD_LOGIC;
    signal comp_less    : STD_LOGIC;
    signal comp_greater : STD_LOGIC;

    -----------------------------------------------------------------------
    -- MUL Signal
    -----------------------------------------------------------------------
    signal product_int : STD_LOGIC_VECTOR(7 downto 0);

    -----------------------------------------------------------------------
    -- Final Output Signals
    -----------------------------------------------------------------------
    signal result_4b    : STD_LOGIC_VECTOR(3 downto 0);
    signal overflow_int : STD_LOGIC;

begin

    -----------------------------------------------------------------------
    -- 1. Add_Sub_4_bit Instantiation
    --    ADD (0000): as_A=A,      as_B=B, CTRL=0
    --    SUB (0001): as_A=A,      as_B=B, CTRL=1
    --    NEG (0010): as_A="0000", as_B=B, CTRL=1  (computes 0 - B)
    --    others    : as_A=A,      as_B=B, CTRL=0  (result ignored)
    -----------------------------------------------------------------------
    AddSub_Inst : Add_Sub_4_bit
        port map (
            A_AS     => as_A,
            B_AS     => as_B,
            CTRL     => as_CTRL,
            S_AS     => as_result,
            Zero     => as_zero,
            OverFlow => as_overflow
        );

    -- Input steering
    as_A    <= "0000" when Op = "0010"          -- NEG: force A to zero
               else A;

    as_B    <= B;                                -- B always from register

    as_CTRL <= '1'    when (Op = "0001"          -- SUB
                         or Op = "0010")         -- NEG
               else '0';                         -- ADD and others

    -----------------------------------------------------------------------
    -- 2. Comparator_4_bit Instantiation
    --    Always running, compares A and B using signed arithmetic
    --    EQ (1000): comp_equal   driven to Result and Equal_Flag port
    --    GT (1001): comp_greater driven to Result and GreaterThan_Flag port
    --    LT (1010): comp_less    driven to Result and LessThan_Flag port
    -----------------------------------------------------------------------
    Comp_Inst : Comparator_4_bit
        port map (
            Input_A          => A,
            Input_B          => B,
            Equal_Flag       => comp_equal,
            LessThan_Flag    => comp_less,
            GreaterThan_Flag => comp_greater
        );

    -- Connect comparator flags to ALU output ports
    -- These go directly to LED(11), LED(12), LED(13) in NanoProcessor
    Equal_Flag       <= comp_equal;
    LessThan_Flag    <= comp_less;
    GreaterThan_Flag <= comp_greater;

    -----------------------------------------------------------------------
    -- 3. MUL: A * B full 8-bit product, lower 4 bits returned
    -----------------------------------------------------------------------
    product_int <= std_logic_vector(unsigned(A) * unsigned(B));

    -----------------------------------------------------------------------
    -- 4. Result MUX
    --    Selects correct result based on opcode
    -----------------------------------------------------------------------
    result_4b <=
        as_result                when (Op = "0000" or   -- ADD
                                       Op = "0001" or   -- SUB
                                       Op = "0010")     -- NEG
        else
        product_int(3 downto 0)  when  Op = "0011"      -- MUL
        else
        (A and B)                when  Op = "0100"      -- AND
        else
        (A or B)                 when  Op = "0101"      -- OR
        else
        "000" & comp_equal       when  Op = "1000"      -- EQ
        else
        "000" & comp_greater     when  Op = "1001"      -- GT
        else
        "000" & comp_less        when  Op = "1010"      -- LT
        else
        "0000";                                         -- NOP/others

    -----------------------------------------------------------------------
    -- 5. Overflow
    --    ADD/SUB/NEG: carry-out from Add_Sub_4_bit
    --    MUL        : upper nibble of product non-zero
    --    others     : always '0'
    -----------------------------------------------------------------------
    overflow_int <=
        as_overflow
            when (Op = "0000" or
                  Op = "0001" or
                  Op = "0010")
        else
        '1' when (Op = "0011" and
                  product_int(7 downto 4) /= "0000")
        else
        '0';

    -----------------------------------------------------------------------
    -- 6. Zero Flag
    --    '1' when final result is "0000"
    -----------------------------------------------------------------------
    Zero <= '1' when result_4b = "0000" else '0';

    -----------------------------------------------------------------------
    -- 7. Output Assignments
    -----------------------------------------------------------------------
    Result   <= result_4b;
    Overflow <= overflow_int;

end Structural;