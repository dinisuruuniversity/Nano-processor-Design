----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 02:10:02 PM
-- Design Name: 
-- Module Name: TB_Instruction_Decoder - Behavioral
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
use work.BusDefinitions.all;
use work.constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_Instruction_Decoder is
--  Port ( );
end TB_Instruction_Decoder;

architecture Behavioral of TB_Instruction_Decoder is

    component Instruction_Decoder
    port(
    Instruction : in InstructionWord;
    Register_Value_For_Jump: in DataBus;
    Register_Enable  : out RegisterSelect;
    Register_Select_A :out RegisterSelect;
    Register_Select_B : out RegisterSelect;
     ALU_Op  : out STD_LOGIC_VECTOR(2 downto 0);
    Immediate_Value : out DataBus;
    Jump_Enable: out STD_LOGIC;
    Jump_Address : out ProgramCounter;
    Load_Select :out STD_LOGIC
    );
  end component;
    

--Inputs--
signal tb_Instruction:InstructionWord:=(others=>'0');
signal tb_Register_Value : DataBus :=(others=>'0');

--Outputs
signal tb_Register_Enable :RegisterSelect;
signal tb_Register_Select_A:RegisterSelect;
signal tb_Register_Select_B:RegisterSelect;
signal tb_Operation_Select :STD_LOGIC_VECTOR(2 downto 0);
signal tb_Immediate_Value : DataBus;
signal tb_Jump_Enable : STD_LOGIC;
signal tb_Jump_Address : ProgramCounter;
signal tb_Load_Select : STD_LOGIC;


begin

uut:Instruction_Decoder
port map(
Instruction=>tb_Instruction,
Register_Value_For_Jump=>tb_Register_Value,
Register_Enable=> tb_Register_Enable,
Register_Select_A=>tb_Register_Select_A,
Register_Select_B=>tb_Register_Select_B,
ALU_Op=>tb_Operation_Select,
Immediate_Value=>tb_Immediate_Value,
Jump_Enable=>tb_Jump_Enable,
Jump_Address => tb_Jump_Address,
Load_Select => tb_Load_Select
);
 simulation_process: process
 begin
 -- Wait 100 ns
 wait for 100 ns;
  --index number:11 010 101 111 010 001
 --Test MOVI instruction
 --

 --MOVI R2,1 (MOVE immediate value 1 to R2)
 tb_Instruction<=MOVI_OP &"010" &"000" &"0" &"001";

wait for 20ns;

--Test Add instruction
-- ADD R7, R4 (Add R7 = R7 + R4)
tb_Instruction <= ADD_OP & "111" & "100" & "0000";
wait for 20 ns;

-- Test NEG instruction
-- NEG R5 (R5 = -R5 = 0 - R5)
tb_Instruction <= NEG_OP & "101" & "0000000";
wait for 20 ns;

-- Test JZR instruction with zero register
-- JZR R1, 6 (Jump to address 6 if R1 = 0)
tb_Instruction <= JZR_OP & "001" & "0000" & "110";
tb_Register_Value <= "0000";  -- R1 contains 0
wait for 20 ns;

-- Test JZR instruction with non-zero register
tb_Instruction <= JZR_OP & "001" & "0000" & "111";
tb_Register_Value <= "0010";  -- R1 contains non-zero

wait for 20 ns;
report "Simulation Finished Successfully";

wait;

end process;
end Behavioral;
