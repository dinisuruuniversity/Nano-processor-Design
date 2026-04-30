

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

        
        ALU_Op                  : out STD_LOGIC_VECTOR(2 downto 0);
        
        Immediate_Value         : out DataBus;                   
        Load_Select             : out STD_LOGIC;                 

        Jump_Enable             : out STD_LOGIC;                 
        Jump_Address            : out ProgramCounter             
    );
end entity Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    signal Opcode : std_logic_vector(2 downto 0);  -- 3-bit opcode
begin

    Opcode <= Instruction(12 downto 10);  

    decode : process(Opcode, Instruction, Register_Value_For_Jump)
    begin
        
        Register_Enable   <= (others => '0');
        Register_Select_A <= (others => '0');
        Register_Select_B <= (others => '0');
        ALU_Op            <= Opcode;          
        Immediate_Value   <= (others => '0');
        Load_Select       <= '0';
        Jump_Enable       <= '0';
        Jump_Address      <= (others => '0');

        case Opcode is

            
            -- 000: ADD Rd, Rs  →  Rd ← Rd + Rs
            
            when ADD_OP =>
                Register_Select_A <= Instruction(9 downto 7);   
                Register_Select_B <= Instruction(6 downto 4);   
                Register_Enable   <= Instruction(9 downto 7);   
                ALU_Op            <= ADD_OP;
                Load_Select       <= '1';

            
            -- 001: SUB Rd, Rs  →  Rd ← Rd - Rs
            
            when SUB_OP =>
                Register_Select_A <= Instruction(9 downto 7);
                Register_Select_B <= Instruction(6 downto 4);
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= SUB_OP;
                Load_Select       <= '1';

            
            -- 010: NEG Rd  →  Rd ← 0 - Rd
            
            when NEG_OP =>
                Register_Select_A <= "000";                     
                Register_Select_B <= Instruction(9 downto 7);   -- Rd becomes operand B
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= NEG_OP;
                Load_Select       <= '1';

            
            -- 011: MUL Rd, Rs  →  Rd ← Rd × Rs (lower 4 bits)
            
            when MUL_OP =>
                Register_Select_A <= Instruction(9 downto 7);
                Register_Select_B <= Instruction(6 downto 4);
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= MUL_OP;
                Load_Select       <= '1';

            
            -- 100: AND Rd, Rs  →  Rd ← Rd AND Rs
            
            when AND_OP =>
                Register_Select_A <= Instruction(9 downto 7);
                Register_Select_B <= Instruction(6 downto 4);
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= AND_OP;
                Load_Select       <= '1';

            
            -- 101: OR Rd, Rs  →  Rd ← Rd OR Rs
            
            when OR_OP =>
                Register_Select_A <= Instruction(9 downto 7);
                Register_Select_B <= Instruction(6 downto 4);
                Register_Enable   <= Instruction(9 downto 7);
                ALU_Op            <= OR_OP;
                Load_Select       <= '1';

            
            -- 110: MOVI Rd, imm4  →  Rd ← imm4
            
            when MOVI_OP =>
                Immediate_Value <= Instruction(3 downto 0);
                Register_Enable <= Instruction(9 downto 7);
                Load_Select     <= '0';                          

           
            -- 111: JZR Rs, addr  →  if Rs=0 then PC ← addr
           
            when JZR_OP =>
                Register_Select_A <= Instruction(9 downto 7);   
                Register_Enable   <= "000";                      -- No register write
                if Register_Value_For_Jump = "0000" then
                    Jump_Enable  <= '1';
                    Jump_Address <= Instruction(2 downto 0);
                else
                    Jump_Enable  <= '0';
                end if;

            when others => null;

        end case;
    end process decode;

end architecture Behavioral;