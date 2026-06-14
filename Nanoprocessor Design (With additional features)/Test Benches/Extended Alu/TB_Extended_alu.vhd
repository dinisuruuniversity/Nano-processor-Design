----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2026 03:53:31 PM
-- Design Name: 
-- Module Name: TB_Extended_alu - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Extended_ALU_TB is
end Extended_ALU_TB;

architecture Behavioral of Extended_ALU_TB is

    component Extended_ALU
        Port (
            A                : in  DataBus;
            B                : in  DataBus;
            Op               : in  STD_LOGIC_VECTOR(3 downto 0);
            Result           : out DataBus;
            Zero             : out STD_LOGIC;
            Overflow         : out STD_LOGIC;
            Equal_Flag       : out STD_LOGIC;
            LessThan_Flag    : out STD_LOGIC;
            GreaterThan_Flag : out STD_LOGIC
        );
    end component;

    signal tb_A        : DataBus                    := (others => '0');
    signal tb_B        : DataBus                    := (others => '0');
    signal tb_Op       : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal tb_Result   : DataBus;
    signal tb_Zero     : STD_LOGIC;
    signal tb_Overflow : STD_LOGIC;
    signal tb_Equal    : STD_LOGIC;
    signal tb_Less     : STD_LOGIC;
    signal tb_Greater  : STD_LOGIC;

begin

    UUT: Extended_ALU
        port map (
            A                => tb_A,
            B                => tb_B,
            Op               => tb_Op,
            Result           => tb_Result,
            Zero             => tb_Zero,
            Overflow         => tb_Overflow,
            Equal_Flag       => tb_Equal,
            LessThan_Flag    => tb_Less,
            GreaterThan_Flag => tb_Greater
        );

    stim_proc: process
    begin
    --Index Number : 240593H
    --Index Binary : 111010101111010001
    -- 4-bit groups : 1110(14) | 1010(10) | 1111(15) | 0100(4) | 0001(1)

        -- TC1: ADD A=1110(14), B=0001(1)
        -- Expect: Result=1111(15), Zero='0', Overflow='0'
        tb_A  <= "1110"; tb_B <= "0001"; tb_Op <= "0000";
        wait for 10 ns;

        -- TC2: ADD A=1010(10), B=0100(4)  -> overflow
        -- Expect: Result=1110(14), Zero='0', Overflow='0'
        tb_A  <= "1010"; tb_B <= "0100"; tb_Op <= "0000";
        wait for 10 ns;

        -- TC3: SUB A=1110(14), B=0100(4)
        -- Expect: Result=1010(10), Zero='0', Overflow='0'
        tb_A  <= "1110"; tb_B <= "0100"; tb_Op <= "0001";
        wait for 10 ns;

        -- TC4: SUB A=0001(1), B=0001(1)  -> zero result
        -- Expect: Result=0000, Zero='1', Overflow='0'
        tb_A  <= "0001"; tb_B <= "0001"; tb_Op <= "0001";
        wait for 10 ns;

        -- TC5: NEG A=1010(10)  -> 0 - 1010
        -- Expect: Result=0110(6 in two's complement), Overflow='0'
        tb_A  <= "1010"; tb_B <= "0000"; tb_Op <= "0010";
        wait for 10 ns;

        -- TC6: NEG A=0000  -> 0 - 0
        -- Expect: Result=0000, Zero='1'
        tb_A  <= "0000"; tb_B <= "0000"; tb_Op <= "0010";
        wait for 10 ns;

        -- TC7: MUL A=1110(14), B=0001(1)
        -- Expect: Result=1110(14), Overflow='0'
        tb_A  <= "1110"; tb_B <= "0001"; tb_Op <= "0011";
        wait for 10 ns;

        -- TC8: MUL A=1010(10), B=0100(4)  -> 40, overflow upper nibble
        -- Expect: Result=1000(lower 4 bits of 40=00101000), Overflow='1'
        tb_A  <= "1010"; tb_B <= "0100"; tb_Op <= "0011";
        wait for 10 ns;

        -- TC9: AND A=1110(14), B=1010(10)
        -- Expect: Result=1010(10), Zero='0'
        tb_A  <= "1110"; tb_B <= "1010"; tb_Op <= "0100";
        wait for 10 ns;

        -- TC10: AND A=1010(10), B=0100(4)
        -- Expect: Result=0000, Zero='1'
        tb_A  <= "1010"; tb_B <= "0100"; tb_Op <= "0100";
        wait for 10 ns;

        -- TC11: OR A=1010(10), B=0100(4)
        -- Expect: Result=1110(14), Zero='0'
        tb_A  <= "1010"; tb_B <= "0100"; tb_Op <= "0101";
        wait for 10 ns;

        -- TC12: OR A=0000, B=0000
        -- Expect: Result=0000, Zero='1'
        tb_A  <= "0000"; tb_B <= "0000"; tb_Op <= "0101";
        wait for 10 ns;

        -- TC13: EQ A=1010(10), B=1010(10)  -> equal
        -- Expect: Result=0001, Equal='1', Less='0', Greater='0'
        tb_A  <= "1010"; tb_B <= "1010"; tb_Op <= "1000";
        wait for 10 ns;

        -- TC14: EQ A=1110(14), B=0001(1)   -> not equal
        -- Expect: Result=0000, Equal='0'
        tb_A  <= "1110"; tb_B <= "0001"; tb_Op <= "1000";
        wait for 10 ns;

        -- TC15: GT A=1110(14), B=0100(4)   -> A > B
        -- Expect: Result=0001, Greater='1', Equal='0', Less='0'
        tb_A  <= "1110"; tb_B <= "0100"; tb_Op <= "1001";
        wait for 10 ns;

        -- TC16: GT A=0001(1), B=1010(10)   -> A < B, not greater
        -- Expect: Result=0000, Greater='0'
        tb_A  <= "0001"; tb_B <= "1010"; tb_Op <= "1001";
        wait for 10 ns;

        -- TC17: LT A=0001(1), B=1010(10)   -> A < B
        -- Expect: Result=0001, Less='1', Equal='0', Greater='0'
        tb_A  <= "0001"; tb_B <= "1010"; tb_Op <= "1010";
        wait for 10 ns;

        -- TC18: LT A=1110(14), B=0100(4)   -> A > B, not less
        -- Expect: Result=0000, Less='0'
        tb_A  <= "1110"; tb_B <= "0100"; tb_Op <= "1010";
        wait for 10 ns;

        wait;
    end process;

end Behavioral;