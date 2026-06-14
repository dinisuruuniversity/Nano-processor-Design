----------------------------------------------------------------------------------
-- Module Name: Instruction_Decoder_TB - Behavioral
-- Description: Testbench for Instruction_Decoder

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;
use work.constants.all;

entity Instruction_Decoder_TB is
end Instruction_Decoder_TB;

architecture Behavioral of Instruction_Decoder_TB is

    component Instruction_Decoder
        port (
            Instruction             : in  InstructionWord;
            Register_Value_For_Jump : in  DataBus;
            Register_Enable         : out RegisterSelect;
            Register_Select_A       : out RegisterSelect;
            Register_Select_B       : out RegisterSelect;
            ALU_Op                  : out STD_LOGIC_VECTOR(3 downto 0);
            Immediate_Value         : out DataBus;
            Load_Select             : out STD_LOGIC;
            Jump_Enable             : out STD_LOGIC;
            Jump_Address            : out ProgramCounter
        );
    end component;

    signal tb_Instruction  : InstructionWord := (others => '0');
    signal tb_Reg_Val_Jump : DataBus         := (others => '0');
    signal tb_Reg_Enable   : RegisterSelect;
    signal tb_Reg_Sel_A    : RegisterSelect;
    signal tb_Reg_Sel_B    : RegisterSelect;
    signal tb_ALU_Op       : STD_LOGIC_VECTOR(3 downto 0);
    signal tb_Immediate    : DataBus;
    signal tb_Load_Select  : STD_LOGIC;
    signal tb_Jump_Enable  : STD_LOGIC;
    signal tb_Jump_Address : ProgramCounter;

begin

    UUT: Instruction_Decoder
        port map (
            Instruction             => tb_Instruction,
            Register_Value_For_Jump => tb_Reg_Val_Jump,
            Register_Enable         => tb_Reg_Enable,
            Register_Select_A       => tb_Reg_Sel_A,
            Register_Select_B       => tb_Reg_Sel_B,
            ALU_Op                  => tb_ALU_Op,
            Immediate_Value         => tb_Immediate,
            Load_Select             => tb_Load_Select,
            Jump_Enable             => tb_Jump_Enable,
            Jump_Address            => tb_Jump_Address
        );

    stim_proc: process
    begin
    --Index Number : 240593H
    --Index Binary : 111010101111010001
    --4-bit groups : 1110 | 1010 | 1111 | 0100 | 0001
    --Immediates   : 1110(14) | 1010(10) | 1111(15) | 0100(4) | 0001(1)
    -- Registers    : 111=R7  | 010=R2  | 100=R4  | 001=R1

        -- TC1: ADD R7, R2   opcode=0000 Rd=111 Rs=010
        -- Expect: Reg_Enable=111, Sel_A=111, Sel_B=010, ALU_Op=0000, Load_Select='1'
        tb_Instruction  <= "0000" & "111" & "010" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC2: SUB R4, R1   opcode=0001 Rd=100 Rs=001
        -- Expect: Reg_Enable=100, Sel_A=100, Sel_B=001, ALU_Op=0001, Load_Select='1'
        tb_Instruction  <= "0001" & "100" & "001" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC3: NEG R7        opcode=0010 Rd=111
        -- Expect: Reg_Enable=111, Sel_A=000(R0 forced), Sel_B=111, ALU_Op=0010, Load_Select='1'
        tb_Instruction  <= "0010" & "111" & "000" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC4: MUL R2, R1   opcode=0011 Rd=010 Rs=001
        -- Expect: Reg_Enable=010, Sel_A=010, Sel_B=001, ALU_Op=0011, Load_Select='1'
        tb_Instruction  <= "0011" & "010" & "001" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC5: AND R7, R4   opcode=0100 Rd=111 Rs=100
        -- Expect: Reg_Enable=111, Sel_A=111, Sel_B=100, ALU_Op=0100, Load_Select='1'
        tb_Instruction  <= "0100" & "111" & "100" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC6: OR R4, R2    opcode=0101 Rd=100 Rs=010
        -- Expect: Reg_Enable=100, Sel_A=100, Sel_B=010, ALU_Op=0101, Load_Select='1'
        tb_Instruction  <= "0101" & "100" & "010" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC7: MOVI R7, 1110  opcode=0110 Rd=111 imm=1110 (14 from index group 1)
        -- Expect: Reg_Enable=111, Immediate=1110, Load_Select='0'
        tb_Instruction  <= "0110" & "111" & "000" & "1110";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC8: MOVI R2, 1010  opcode=0110 Rd=010 imm=1010 (10 from index group 2)
        -- Expect: Reg_Enable=010, Immediate=1010, Load_Select='0'
        tb_Instruction  <= "0110" & "010" & "000" & "1010";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC9: JZR R2, 0100  Jump TAKEN  (R2 = 0000)
        -- Expect: Sel_A=010, Reg_Enable=000, Jump_Enable='1', Jump_Address=0100
        tb_Instruction  <= "0111" & "010" & "000" & "0100";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC10: JZR R7, 0001  Jump NOT TAKEN  (R7 = 1110, non-zero)
        -- Expect: Sel_A=111, Reg_Enable=000, Jump_Enable='0'
        tb_Instruction  <= "0111" & "111" & "000" & "0001";
        tb_Reg_Val_Jump <= "1110";
        wait for 10 ns;

        -- TC11: EQ R7, R2   opcode=1000 Rd=111 Rs=010
        -- Expect: Sel_A=111, Sel_B=010, Reg_Enable=000, Load_Select='0'
        tb_Instruction  <= "1000" & "111" & "010" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC12: GT R4, R1   opcode=1001 Rd=100 Rs=001
        -- Expect: Sel_A=100, Sel_B=001, Reg_Enable=000, Load_Select='0'
        tb_Instruction  <= "1001" & "100" & "001" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        -- TC13: LT R2, R7   opcode=1010 Rd=010 Rs=111
        -- Expect: Sel_A=010, Sel_B=111, Reg_Enable=000, Load_Select='0'
        tb_Instruction  <= "1010" & "010" & "111" & "0000";
        tb_Reg_Val_Jump <= "0000";
        wait for 10 ns;

        wait;
    end process;

end Behavioral;