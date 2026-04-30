library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;
use work.Constants.all;

entity Program_ROM is
    port(
        program_counter : in ProgramCounter;   -- Address input from program counter
        instruction_out : out InstructionWord  -- 12-bit instruction output
    );
end Program_ROM;

architecture Behavioral of Program_ROM is
    -- ROM memory type stores 8 instructions of 12 bits each
    type instruction_memory_type is array (0 to 7) of std_logic_vector(11 downto 0);

    -- Simple arithmetic demo using R6 (110) and R7 (111)
    -- Instruction format:
    --   MOVI : "10" & reg(3b) & "0" & imm(4b)   -> reg <- imm
    --   ADD  : "00" & dst(3b) & src(3b) & "000"  -> dst <- dst + src
    --   NEG  : "01" & dst(3b) & src(3b) & "000"  -> dst <- -src
    --   JZR  : "11" & reg(3b) & addr(4b) & "0"   -> if reg=0 jump to addr
    signal program_instructions : instruction_memory_type := (
        "101110000101", -- 0: MOVI R7, 5  ; R7 <- 5
        "101100000011", -- 1: MOVI R6, 3  ; R6 <- 3
        "001111100000", -- 2: ADD  R7, R6 ; R7 <- R7 + R6 = 8
        "011101100000", -- 3: NEG  R6, R6 ; R6 <- -R6 = -3
        "001111100000", -- 4: ADD  R7, R6 ; R7 <- R7 + R6 = 5
        "011111110000", -- 5: NEG  R7, R7 ; R7 <- -R7 = -5
        "001101110000", -- 6: ADD  R6, R7 ; R6 <- R6 + R7 = -8
        "111110000000"  -- 7: JZR  R7, 0  ; R7 /= 0, no jump -> halt
    );

begin
    -- Map ROM address (program counter) to instruction output
    instruction_out <= program_instructions(to_integer(unsigned(program_counter)));
end Behavioral;