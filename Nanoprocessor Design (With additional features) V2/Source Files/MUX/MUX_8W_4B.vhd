----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 05:20:55 PM
-- Design Name: 
-- Module Name: MUX_8W_4B - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX_8W_4B is
port(
    input1  : in STD_LOGIC_VECTOR(3 downto 0);
    input2  : in STD_LOGIC_VECTOR(3 downto 0);
    input3  : in STD_LOGIC_VECTOR(3 downto 0);
    input4  : in STD_LOGIC_VECTOR(3 downto 0);
    input5  : in STD_LOGIC_VECTOR(3 downto 0);
    input6  : in STD_LOGIC_VECTOR(3 downto 0);
    input7  : in STD_LOGIC_VECTOR(3 downto 0);
    input8  : in STD_LOGIC_VECTOR(3 downto 0);
    slt     : in STD_LOGIC_VECTOR(2 downto 0);
    output  : out STD_LOGIC_VECTOR(3 downto 0)
);
end MUX_8W_4B;

architecture Behavioral of MUX_8W_4B is

begin
    with slt select
    output <= input1 when "000",
              input2 when "001",
              input3 when "010",
              input4 when "011",
              input5 when "100",
              input6 when "101",
              input7 when "110",
              input8 when "111",
              "0000" when others;
end Behavioral;
