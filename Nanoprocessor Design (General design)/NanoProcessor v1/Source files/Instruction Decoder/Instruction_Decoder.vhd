library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;
use work.constants.all;

entity Instruction_Decoder is
    port (
        Instruction             : in  InstructionWord;  -- 12-bit instruction word
        Register_Value_For_Jump : in  DataBus;          -- Register value for JZR condition check
        Register_Enable         : out RegisterSelect;   -- Destination register write enable
        Register_Select_A       : out RegisterSelect;   -- First operand register select
        Register_Select_B       : out RegisterSelect;   -- Second operand register select
        Operation_Select        : out STD_LOGIC;        -- '0'=ADD, '1'=SUB
        Immediate_Value         : out DataBus;          -- Immediate value (MOVI)
        Jump_Enable             : out STD_LOGIC;        -- Jump control flag (JZR)
        Jump_Address            : out ProgramCounter;   -- Jump target address
        Load_Select             : out STD_LOGIC;        -- '0'=immediate, '1'=compute result
        Mul_Select              : out STD_LOGIC         -- '1'=MUL result, '0'=ALU result
    );
end entity Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    signal Opcode : std_logic_vector(1 downto 0);     -- Instruction opcode--store the command part of the instruction
begin
    Opcode <= Instruction(11 downto 10);              -- Extracts the top 2 bits of the instruction
    
    decode: process(Opcode, Register_Value_For_Jump, Instruction)--the sensitivity list
    --opcode -if instruction type chnages change control signals immediately
    --register_value_for_jump- flip jump_enable signal
    --instruction - if 12 bit instruction changes--output must updates
    
    
    begin
    
    
        -- Default assignments to prevent latch inference
        Jump_Enable       <= '0';
        Immediate_Value   <= (others => '0');
        Load_Select       <= '0';
        Register_Enable   <= (others => '0');
        Operation_Select  <= '0';
        Register_Select_A <= (others => '0');
        Register_Select_B <= (others => '0');
        Jump_Address      <= (others => '0');
        Mul_Select        <= '0';                     -- Default: use ALU result
        
        --code looks at the opcode and chooses one of four paths:
        case Opcode is
            when MOVI_OP =>                           -- Move Immediate
                Immediate_Value <= Instruction(3 downto 0);--grabs the last 4 bbits as a constant number
                Load_Select     <= '0';               -- use immediate value
                Register_Enable <= Instruction(9 downto 7);
                
            when ADD_OP =>                            -- Add operation
                Register_Select_A <= Instruction(9 downto 7);
                Register_Select_B <= Instruction(6 downto 4);
                Operation_Select  <= '0';             -- Addition
                Load_Select       <= '1';             -- Register load mode
                Register_Enable   <= Instruction(9 downto 7);
                
            when NEG_OP =>                            -- NEG or MUL (discriminated by bit[3])
                if Instruction(3) = '1' then
                    -- MUL Rd, Rs  →  Rd ← Rd × Rs  (lower 4 bits)
                    -- Encoding: 01 Rd Rs 1xxx
                    Register_Select_A <= Instruction(9 downto 7); -- Rd (multiplicand)
                    Register_Select_B <= Instruction(6 downto 4); -- Rs (multiplier)
                    Mul_Select        <= '1';         -- Route MUL result to write-back
                    Load_Select       <= '1';         -- Use compute path (not immediate)
                    Register_Enable   <= Instruction(9 downto 7); -- Write result to Rd
                else
                    -- NEG Rd  →  Rd ← 0 - Rd  (existing behaviour)
                    Register_Select_A <= "000";       -- R0 (hardwired zero)
                    Register_Select_B <= Instruction(9 downto 7); -- Rd to negate
                    Operation_Select  <= '1';         -- Subtraction mode
                    Load_Select       <= '1';         -- Use ALU result
                    Register_Enable   <= Instruction(9 downto 7); -- Write back to Rd
                end if;
                
            when JZR_OP =>                            -- Jump if Zero
                Register_Select_A <= Instruction(9 downto 7);
                Register_Enable   <= "000";           -- No register writes
                
                -- Check if the value is zero
                if Register_Value_For_Jump = (Register_Value_For_Jump'range => '0') then
                    Jump_Enable   <= '1';             -- Enable jump
                    Jump_Address  <= Instruction(2 downto 0);
                else
                    Jump_Enable   <= '0';             -- No jump
                end if;
                
            when others =>
            null;
                -- All outputs already have default values
        end case;
    end process decode;
end architecture Behavioral;