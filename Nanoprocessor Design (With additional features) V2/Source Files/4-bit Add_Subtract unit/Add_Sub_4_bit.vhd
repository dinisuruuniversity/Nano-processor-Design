----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 02:50:58 PM
-- Design Name: 
-- Module Name: Add_Sub_4_bit - Behavioral
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

entity Add_Sub_4_bit is
    Port ( A_AS : in STD_LOGIC_VECTOR (3 downto 0);
           B_AS : in STD_LOGIC_VECTOR (3 downto 0);
           CTRL : in STD_LOGIC;
           S_AS : out STD_LOGIC_VECTOR (3 downto 0);
           Zero : out STD_LOGIC;
           OverFlow : out STD_LOGIC);
end Add_Sub_4_bit;

architecture Behavioral of Add_Sub_4_bit is
component RCA_4 is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           C_in : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           C_out : out STD_LOGIC);
end component;

SIGNAL B_inter, S_inter: STD_LOGIC_VECTOR(3 DOWNTO 0);

begin
RCA_4_0 : RCA_4
    port map(
        A => A_AS,
        B => B_inter,
        C_in => CTRL,
        S => S_inter,
        C_out => OverFlow);

  B_inter(0) <= B_AS(0) XOR CTRL; 
  B_inter(1) <= B_AS(1) XOR CTRL;
  B_inter(2) <= B_AS(2) XOR CTRL;
  B_inter(3) <= B_AS(3) XOR CTRL;

  process (S_inter)
  begin
    if S_inter = "0000" then
      Zero <= '1';
    else
      Zero <= '0';
    end if;
  end process;

  S_AS <= S_inter;



end Behavioral;
