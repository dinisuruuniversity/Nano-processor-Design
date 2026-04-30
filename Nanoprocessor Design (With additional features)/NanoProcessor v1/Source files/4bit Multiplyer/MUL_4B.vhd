----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2026 11:39:38 AM
-- Design Name: 
-- Module Name: MUL_4B - Behavioral
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

entity MUL_4B is
    Port(
        in1         : in  DataBus;
        in2         : in  DataBus;      
        result          : out DataBus;     
        overflow  : out STD_LOGIC
    );
end entity MUL_4B;

architecture Behavioral of MUL_4B is
signal Full_Result    : signed(7 downto 0); 
signal Sign_Extension : std_logic_vector(3 downto 0); 
 
begin    
    Full_Result <= signed(in1) * signed(in2);
    result <= std_logic_vector(Full_Result(3 downto 0));
    Sign_Extension <= (others => Full_Result(3));
    
    -- Overflow
    overflow <= '1' when std_logic_vector(Full_Result(7 downto 4)) /= Sign_Extension else '0';
    
end architecture Behavioral;
