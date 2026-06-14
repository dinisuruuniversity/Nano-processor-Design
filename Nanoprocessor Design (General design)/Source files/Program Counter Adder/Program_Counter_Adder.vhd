----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 03:24:27 PM
-- Design Name: 
-- Module Name: Program_Counter_Adder - Behavioral
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
use work.BusDefinitions.ProgramCounter;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter_Adder is
port(
    currAddress : in ProgramCounter;
    nxtAddress  : out ProgramCounter
);
end Program_Counter_Adder;

architecture Behavioral of Program_Counter_Adder is

component RCA_3
    port(
       A : in STD_LOGIC_VECTOR (2 downto 0);
       B : in STD_LOGIC_VECTOR (2 downto 0);
       C_in : in STD_LOGIC;
       S : out STD_LOGIC_VECTOR (2 downto 0);
       C_out : out STD_LOGIC
    );
end component;

constant incrValue : STD_LOGIC_VECTOR(2 downto 0) := "001";

begin
    address_RCA : RCA_3 port map(
        A=>currAddress,
        B=>incrValue,
        C_in => '0',
        S => nxtAddress,
        C_out => open
    );


end Behavioral;
