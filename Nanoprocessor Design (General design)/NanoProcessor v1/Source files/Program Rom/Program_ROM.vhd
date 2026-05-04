----------------------------------------------------------------------------------
-- Module Name:  Program_ROM - Behavioral
-- Description:  8-location x 12-bit ROM storing the nanoprocessor program.
--
--  Instruction encoding (12 bits):
--    [11:10] = opcode   [9:7] = Reg_A   [6:4] = Reg_B   [3:0] = immediate
--    10 = MOVI,  00 = ADD,  01 = NEG,  11 = JZR
--
--  Loaded program â€“ sum integers 1 to 3, result ends up in R1:
--
--    Addr 0: MOVI R1, 1   â†’ 10_001_000_0001  = "100001000001"  (R1 â†? 1)
--    Addr 1: MOVI R2, 2   â†’ 10_010_000_0010  = "100010000010"  (R2 â†? 2)
--    Addr 2: ADD  R1, R2  â†’ 00_001_010_0000  = "000001010000"  (R1 â†? R1+R2 = 3)
--    Addr 3: MOVI R2, 3   â†’ 10_010_000_0011  = "100010000011"  (R2 â†? 3)
--    Addr 4: ADD  R1, R2  â†’ 00_001_010_0000  = "000001010000"  (R1 â†? R1+R2 = 6)
--    Addr 5: JZR  R0, 5   â†’ 11_000_000_0101  = "110000000101"  (halt: loop to 5)
--    Addr 6: NOP  (unused)â†’ "000000000000"
--    Addr 7: NOP  (unused)â†’ "000000000000"
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
        data    : out InstructionWord    -- 12-bit instruction output
    );
end Program_ROM;

architecture Behavioral of Program_ROM is

    -- ROM type: 8 locations, each 12 bits wide
    type rom_type is array (0 to 7) of InstructionWord;

    constant ROM : rom_type := (
        --            opcode Rd  Rb  immediate
        --              [11:10][9:7][6:4][3:0]
        0 => "101110000001",  -- MOVI R7, 1   â†’ R1 â†? 0001  (bits[9:7]="001"=R1)
        1 => "100100000010",  -- MOVI R2, 2   â†’ R2 â†? 0010  (bits[9:7]="010"=R2)
        2 => "001110100000",  -- ADD  R7, R2  â†’ R1 â†? R1+R2 (bits[9:7]="001"=R1, bits[6:4]="010"=R2)
        3 => "100100000011",  -- MOVI R2, 3   â†’ R2 â†? 0011  (bits[9:7]="010"=R2)
        4 => "001110100000",  -- ADD  R7, R2  â†’ R1 â†? R1+R2 (same as addr 2, result = 6)
        5 => "110000000101",  -- JZR  R0, 5   â†’ halt: loop to addr 5 forever (R0=0 always)
        6 => "000000000000",  -- NOP (unused)
        7 => "000000000000"   -- NOP (unused)
    );

begin
    -- Combinational ROM read
    data <= ROM(to_integer(unsigned(address)));

end Behavioral;
