----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 05:13:10 PM
-- Design Name: 
-- Module Name: MUX_2W_4B - Behavioral
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

entity MUX_2W_4B is
port (
    input1 : in STD_LOGIC_VECTOR(3 downto 0);
    input2 : in STD_LOGIC_VECTOR(3 downto 0);
    slt : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(3 downto 0)
);
end MUX_2W_4B;

architecture Behavioral of MUX_2W_4B is
begin
    output <= input1 when slt = '0' else input2;
end Behavioral;
