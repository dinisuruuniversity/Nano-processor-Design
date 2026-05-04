----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 05:27:58 PM
-- Design Name: 
-- Module Name: TB_Adress_Selector - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Address_Selector_TB is
end Address_Selector_TB;

architecture Behavioral of Address_Selector_TB is

    component Address_Selector is
        port (
            Sequential_Address : in  ProgramCounter;
            Jump_Address       : in  ProgramCounter;
            Jump_Enable        : in  std_logic;
            Selected_Address   : out ProgramCounter
        );
    end component;
    
    signal tb_SeqAddr  : ProgramCounter := (others => '0');
    signal tb_JumpAddr : ProgramCounter := (others => '1');
    signal tb_JumpEn   : std_logic      := '0';
    signal tb_Selected : ProgramCounter;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: Address_Selector
        port map (
            Sequential_Address => tb_SeqAddr,
            Jump_Address       => tb_JumpAddr,
            Jump_Enable        => tb_JumpEn,
            Selected_Address   => tb_Selected
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial Wait
        wait for 100 ns;
       
        -- Case 1: Jump_Enable = 0 (Expect Sequential Path)
        tb_SeqAddr  <= "011"; 
        tb_JumpAddr <= "101"; 
        tb_JumpEn   <= '0';
        wait for 20 ns;
        

        -- Case 2: Jump_Enable = 1 (Expect Jump Path)
        tb_JumpEn <= '1';
        wait for 20 ns;
       

        -- Case 3: Update addresses while Jump_Enable is high
        tb_SeqAddr  <= "110";
        tb_JumpAddr <= "010";
        wait for 20 ns;
        
        -- Case 4: Switch back to Sequential
        tb_JumpEn <= '0';
        wait for 20 ns;
        
        wait; -- Stop the process from looping
    end process;

end Behavioral;