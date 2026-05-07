----------------------------------------------------------------------------------
-- Module Name:  Program_ROM - Behavioral
-- Description:  15-location x 14-bit ROM storing the nanoprocessor program.
--
--  Instruction encoding (14 bits):
--    [13:10] = opcode   [9:7] = Reg_A   [6:4] = Reg_B   [3:0] = immediate
--    10 = MOVI,  00 = ADD,  01 = NEG,  11 = JZR

--
-- Dependencies:
--   Packages/BusDefinitions.vhd  (ProgramCounter, InstructionWord)
--
-- Compile order:
--   1. BusDefinitions.vhd
--   2. Program_ROM.vhd
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Program_ROM is
    Port (
        address : in  ProgramCounter;    -- 3-bit address (0-7)
        data    : out InstructionWord    -- 14-bit instruction output
    );
end Program_ROM;

architecture Behavioral of Program_ROM is

    -- ROM type: 8 locations, each 12 bits wide
    type rom_type is array (0 to 15) of InstructionWord;

    constant ROM : rom_type := (
             -- Initialize registers with test values
-- Address 0: MOVI R7, 5  (110 111 000 0101)
                         -- Address 0: MOVI R7, 4  ? opcode=0110, Rd=111, imm=0100
0  => "0110" & "111" & "000" & "0100",  -- R7 = 4

-- Address 1: MOVI R6, 2  ? opcode=0110, Rd=110, imm=0010
1  => "0110" & "110" & "000" & "0010",  -- R6 = 2

-- Address 2: MUL R7, R6  ? opcode=0011, Rd=111, Rs=110
-- R7 = R7 * R6 = 4 * 2 = 8 ? shown on 7-seg and LED(3:0)
2  => "0011" & "111" & "110" & "0000",  -- R7 = 8

-- Address 3: ADD R7, R6  ? opcode=0000, Rd=111, Rs=110
-- R7 = R7 + R6 = 8 + 2 = 10 ? shown on 7-seg and LED(3:0)
3  => "0000" & "111" & "110" & "0000",  -- R7 = 10

-- Address 4: EQ R7, R6   ? opcode=1000, Rd=111, Rs=110
-- Compares R7(10) vs R6(2) ? not equal ? LED(11)=0
4  => "1000" & "111" & "110" & "0000",

-- Address 5: GT R7, R6   ? opcode=1001, Rd=111, Rs=110
-- R7(10) > R6(2) ? LED(13)=1
5  => "1001" & "111" & "110" & "0000",

-- Address 6: LT R7, R6   ? opcode=1010, Rd=111, Rs=110
-- R7(10) < R6(2) ? false ? LED(12)=0
6  => "1010" & "111" & "110" & "0000",

-- Address 7: HALT ? JZR R0, 7 (R0=0 always ? loops to addr 7)
7  => "0111" & "000" & "000" & "0111",  -- HALT 

-- Addresses 8-15: NOP
8  => "0000" & "000" & "000" & "0000",
9  => "0000" & "000" & "000" & "0000",
10 => "0000" & "000" & "000" & "0000",
11 => "0000" & "000" & "000" & "0000",
12 => "0000" & "000" & "000" & "0000",
13 => "0000" & "000" & "000" & "0000",
14 => "0000" & "000" & "000" & "0000",
15 => "0000" & "000" & "000" & "0000"
);
begin
    -- Combinational ROM read
    data <= ROM(to_integer(unsigned(address)));

end Behavioral;