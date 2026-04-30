----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2026 11:45:03 AM
-- Design Name: 
-- Module Name: MUL_4B_sim - Behavioral
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

entity MUL_4B_sim is
-- port()
end entity MUL_4B_sim;

architecture Behavioral of MUL_4B_sim is
component MUL_4B is
    Port(
        in1       : in  DataBus;
        in2       : in  DataBus;
        result    : out DataBus;
        overflow  : out STD_LOGIC
    );
end component;

signal inpt1   : DataBus := "0000";
signal inpt2   : DataBus := "0000";
signal rslt    : DataBus;
signal ovflw   : STD_LOGIC;
    
begin
UUT: MUL_4B
port map (
    in1     => inpt1,
    in2     => inpt2,
    result  => rslt,
    overflow  => ovflw
);

process
begin
-- Index No : 240604V;
-- Binary representation : 11 1010 1011 1101 1100

-- Index No : 240593H;
-- Binary Representation : 11 1010 1011 1101 0001

    inpt1 <= "1100";  -- 12
    inpt2 <= "1101";  -- 13
    wait for 100 ns;

    inpt1 <= "1011";  -- 11
    inpt2 <= "1010";  -- 10
    wait for 100 ns;
    
    inpt1 <= "0001";  -- 1
    inpt2 <= "1101";  -- 13
    wait for 100ns;
    
    inpt1 <= "0010";  -- 2
    inpt2 <= "0100";  -- 4
    wait for 100 ns;

    inpt1 <= "0101";  -- 5
    inpt2 <= "0011";  -- 3
    wait for 100 ns;
    wait;
end process;
end architecture Behavioral;