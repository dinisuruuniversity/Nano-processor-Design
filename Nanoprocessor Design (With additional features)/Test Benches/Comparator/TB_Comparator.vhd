----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2026 08:37:29 AM
-- Design Name: 
-- Module Name: TB_Comparator - Behavioral
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

entity Comparator_4_bit_TB is
-- Testbench has no ports
end Comparator_4_bit_TB;

architecture Behavioral of Comparator_4_bit_TB is
    -- Component declaration for the Unit Under Test
    component Comparator_4_bit
        Port(
            Input_A           : in  DataBus;
            Input_B           : in  DataBus;
            Equal_Flag        : out STD_LOGIC;
            LessThan_Flag     : out STD_LOGIC;
            GreaterThan_Flag  : out STD_LOGIC
        );
    end component;
    
    -- Test signals
    signal tb_Input_A          : DataBus := (others => '0');
    signal tb_Input_B          : DataBus := (others => '0');
    signal tb_Equal            : STD_LOGIC;
    signal tb_LessThan         : STD_LOGIC;
    signal tb_GreaterThan      : STD_LOGIC;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: Comparator_4_bit 
    port map (
        Input_A          => tb_Input_A,
        Input_B          => tb_Input_B,
        Equal_Flag       => tb_Equal,
        LessThan_Flag    => tb_LessThan,
        GreaterThan_Flag => tb_GreaterThan
    );
    
    -- Stimulus process
    stim_proc: process
    begin
    --index number 240593H
   -- 111010101111010001
   --4-bit groups: 1110 | 1010 | 1111 | 0100 | 01
   
          -- Test case 1: Equal
         -- A = 1010 (10), B = 1010 (10) ? Equal
         tb_Input_A <= "1010";
         tb_Input_B <= "1010";
         wait for 10 ns;
         
         -- Test case 2: Equal
         -- A = 0100 (4), B = 0100 (4) ? Equal
         tb_Input_A <= "0100";
         tb_Input_B <= "0100";
         wait for 10 ns;
         
         -- Test case 3: Equal
         -- A = 0001 (1), B = 0001 (1) ? Equal
         tb_Input_A <= "0001";
         tb_Input_B <= "0001";
         wait for 10 ns;
         
         -- Test case 4: A < B
         -- A = 0100 (4), B = 1010 (10) ? LessThan
         tb_Input_A <= "0100";
         tb_Input_B <= "1010";
         wait for 10 ns;
         
         -- Test case 5: A < B
         -- A = 0001 (1), B = 0100 (4) ? LessThan
         tb_Input_A <= "0001";
         tb_Input_B <= "0100";
         wait for 10 ns;
         
         -- Test case 6: A < B
         -- A = 0001 (1), B = 1111 (15) ? LessThan
         tb_Input_A <= "0001";
         tb_Input_B <= "1111";
         wait for 10 ns;
         
         -- Test case 7: A > B
         -- A = 1110 (14), B = 1010 (10) ? GreaterThan
         tb_Input_A <= "1110";
         tb_Input_B <= "1010";
         wait for 10 ns;
         
         -- Test case 8: A > B
         -- A = 1010 (10), B = 0100 (4) ? GreaterThan
         tb_Input_A <= "1010";
         tb_Input_B <= "0100";
         wait for 10 ns;
         
         -- Test case 9: A > B
         -- A = 1111 (15), B = 0001 (1) ? GreaterThan
         tb_Input_A <= "1111";
         tb_Input_B <= "0001";
         wait for 10 ns;
         
         -- End of test
         wait;
    end process;

end Behavioral;