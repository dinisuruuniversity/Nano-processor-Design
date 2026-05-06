library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;
use work.constants.all;

entity Instruction_Decoder is
    port (
        
        Instruction             : in  InstructionWord;           
        Register_Value_For_Jump : in  DataBus;                   

        
        Register_Enable         : out RegisterSelect;            
        Register_Select_A       : out RegisterSelect;            
        Register_Select_B       : out RegisterSelect;            

        
        ALU_Op                  : out STD_LOGIC_VECTOR(3 downto 0); -- Changed to 4-bit
        
        Immediate_Value         : out DataBus;                   
        Load_Select             : out STD_LOGIC;                 

        Jump_Enable             : out STD_LOGIC;                 
        Jump_Address            : out ProgramCounter             
    );
end entity Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    signal Opcode : std_logic_vector(3 downto 0);  -- 4-bit opcode (bits 13-10)
begin

    Opcode <= Instruction(13 downto 10);  

    decode : process(Opcode, Instruction, Register_Value_For_Jump)
    begin
        
        Register_Enable   <= (others => '0');
        Register_Select_A <= (others => '0');
        Register_Select_B <= (others => '0');
        ALU_Op            <= Opcode;           -- Pass the 4-bit opcode directly to ALU
        Immediate_Value   <= (others => '0');
        Load_Select       <= '0';
        Jump_Enable       <= '0';
        Jump_Address      <= (others => '0');

        case Opcode is

            --------------------------------------------------------------------
            -- 0000: ADD Rd, Rs  ->  Rd <= Rd + Rs
            --------------------------------------------------------------------
            when ADD_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd (destination also source A)
                Register_Select_B <= Instruction(6 downto 4);   -- Rs (source B)
                Register_Enable   <= Instruction(9 downto 7);   -- Write back to Rd
                ALU_Op            <= ADD_OP;
                Load_Select       <= '1';                        -- Use ALU result

            --------------------------------------------------------------------
            -- 0001: SUB Rd, Rs  ->  Rd <= Rd - Rs
            --------------------------------------------------------------------
            when SUB_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= SUB_OP;
                Load_Select       <= '1';

            --------------------------------------------------------------------
            -- 0010: NEG Rd  ->  Rd <= 0 - Rd
            --------------------------------------------------------------------
            when NEG_OP =>
                Register_Select_A <= "000";                      -- R0 (always zero)
                Register_Select_B <= Instruction(9 downto 7);   -- Rd becomes source B
                Register_Enable   <= Instruction(9 downto 7);   -- Write back to Rd
                ALU_Op            <= NEG_OP;
                Load_Select       <= '1';

            --------------------------------------------------------------------
            -- 0011: MUL Rd, Rs  ->  Rd <= Rd * Rs (lower 4 bits)
            --------------------------------------------------------------------
            when MUL_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= MUL_OP;
                Load_Select       <= '1';

            --------------------------------------------------------------------
            -- 0100: AND Rd, Rs  ->  Rd <= Rd AND Rs
            --------------------------------------------------------------------
            when AND_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= AND_OP;
                Load_Select       <= '1';

            --------------------------------------------------------------------
            -- 0101: OR Rd, Rs  ->  Rd <= Rd OR Rs
            --------------------------------------------------------------------
            when OR_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= OR_OP;
                Load_Select       <= '1';

            --------------------------------------------------------------------
            -- 0110: MOVI Rd, imm4  ->  Rd <= immediate value
            --------------------------------------------------------------------
            when MOVI_OP =>
                Immediate_Value    <= Instruction(3 downto 0);   -- 4-bit immediate
                Register_Enable    <= Instruction(9 downto 7);   -- Rd
                Load_Select        <= '0';                       -- Use immediate, not ALU
                -- ALU_Op is set but will be ignored since Load_Select='0'

            --------------------------------------------------------------------
            -- 0111: JZR Rs, addr  ->  if Rs = 0 then PC <= addr
            --------------------------------------------------------------------
            when JZR_OP =>
                Register_Select_A  <= Instruction(9 downto 7);   -- Rs to check for zero
                Register_Enable    <= "000";                     -- No register write
                -- Jump condition:
                if Register_Value_For_Jump = "0000" then
                    Jump_Enable     <= '1';
                    Jump_Address    <= Instruction(2 downto 0);  -- 3-bit jump address
                else
                    Jump_Enable     <= '0';
                end if;

            --------------------------------------------------------------------
            -- 1000: CMP_EQ Rd, Rs  ->  Rd <= 1 if Rd = Rs else 0
            --------------------------------------------------------------------
            when EQ_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);   -- Write result to Rd
                ALU_Op            <= EQ_OP;                     -- 4-bit opcode "1000"
                Load_Select       <= '1';                       -- Use ALU result

            --------------------------------------------------------------------
            -- 1001: CMP_GT Rd, Rs  ->  Rd <= 1 if Rd > Rs else 0
            --------------------------------------------------------------------
            when GT_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);   -- Write result to Rd
                ALU_Op            <= GT_OP;                     -- 4-bit opcode "1001"
                Load_Select       <= '1';                       -- Use ALU result

            --------------------------------------------------------------------
            -- 1010: CMP_LT Rd, Rs  ->  Rd <= 1 if Rd < Rs else 0
            --------------------------------------------------------------------
            when LT_OP =>
                Register_Select_A <= Instruction(9 downto 7);   -- Rd
                Register_Select_B <= Instruction(6 downto 4);   -- Rs
                Register_Enable   <= Instruction(9 downto 7);   -- Write result to Rd
                ALU_Op            <= LT_OP;                     -- 4-bit opcode "1010"
                Load_Select       <= '1';                       -- Use ALU result

            --------------------------------------------------------------------
            -- Default: Any other opcode does nothing
            --------------------------------------------------------------------
            when others =>
                -- All outputs already initialized to '0' or default values
                null;

        end case;
    end process decode;

end architecture Behavioral;