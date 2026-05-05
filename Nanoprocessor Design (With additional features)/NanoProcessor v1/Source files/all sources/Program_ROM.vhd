

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Program_ROM is
    Port (
        program_counter : in  ProgramCounter;   -- 3-bit address from PC
        instruction_out : out InstructionWord   -- 13-bit instruction output
    );
end Program_ROM;

architecture Behavioral of Program_ROM is

    type rom_type is array (0 to 7) of InstructionWord;

    constant ROM : rom_type := (
        --            opc  Rd   Rb   imm4
        --           [12:10][9:7][6:4][3:0]
        0 => "1100010000001",  -- MOVI R1, 1   -> R1 <- 0001
        1 => "1100100000010",  -- MOVI R2, 2   -> R2 <- 0010
        2 => "0000010100000",  -- ADD  R1, R2  -> R1 <- R1 + R2 (= 3)
        3 => "1100100000011",  -- MOVI R2, 3   -> R2 <- 0011
        4 => "0000010100000",  -- ADD  R1, R2  -> R1 <- R1 + R2 (= 6)
        5 => "1110000000101",  -- JZR  R0, 5   -> halt (R0=0 always true)
        6 => "0000000000000",  -- NOP
        7 => "0000000000000"   -- NOP
    );

begin
    instruction_out <= ROM(to_integer(unsigned(program_counter)));
end Behavioral;