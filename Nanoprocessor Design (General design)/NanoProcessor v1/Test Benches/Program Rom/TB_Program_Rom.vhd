----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2026 05:07:58 PM
-- Design Name: 
-- Module Name: TB_Program_Rom - Behavioral
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
use work.Constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_Program_Rom is
--  Port ( );
end TB_Program_Rom;

architecture Behavioral of TB_Program_Rom is
 -- Component declaration
   component Program_ROM is
       port(
           address : in ProgramCounter;
           data : out InstructionWord
       );
   end component;

   -- Testbench signals
   signal tb_pc : ProgramCounter := (others => '0');
   signal tb_instruction : InstructionWord;

begin
   -- Instantiate Unit Under Test (UUT)
   UUT: Program_ROM
       port map (
           address => tb_pc,
           data => tb_instruction
       );

   -- Stimulus process
   stim_proc: process
   begin
       for i in 0 to 7 loop
           tb_pc <= std_logic_vector(to_unsigned(i, tb_pc'length));
           wait for 10 ns;
       end loop;
       
       wait;
   end process;

end Behavioral;
