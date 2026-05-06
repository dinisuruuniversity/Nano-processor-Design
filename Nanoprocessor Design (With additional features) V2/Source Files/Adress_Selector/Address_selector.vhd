----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 04:12:05 PM
-- Design Name: 
-- Module Name: Address_selector - Behavioral
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


entity Address_Selector is
    port(
        -- The next address in a normal sequence (usually current PC + 1)
        Sequential_Address : in  ProgramCounter;
        
        -- The target address to go to if a jump condition is met
        Jump_Address       : in  ProgramCounter;
        
        -- Control signal from Instruction Decoder: '0' for Sequential, '1' for Jump
        Jump_Enable        : in  std_logic;
        
        -- The final selected address sent to the Program Counter register
        Selected_Address   : out ProgramCounter
    );
end Address_Selector;

architecture Behavioral of Address_selector is

    Component MUX_2W_3B is
        port (
            input1 : in  ProgramCounter; --  Default path
            input2 : in  ProgramCounter; --  Jump path
            slt    : in  std_logic;      -- Select signal
            output : out ProgramCounter  -- Resulting address
        );
    end component MUX_2W_3B;
    
begin

    Program_Mux : Mux_2W_3B
        port map (
        
            input1 => Sequential_Address, -- Connects PC+1 to Mux Input 0
            input2 => Jump_Address,       -- Connects Jump Target to Mux Input 1
            slt    => Jump_Enable,        -- Uses Jump_Enable as the selector
            output => Selected_Address    -- Drives the output of the module
        );
        
end architecture Behavioral;
