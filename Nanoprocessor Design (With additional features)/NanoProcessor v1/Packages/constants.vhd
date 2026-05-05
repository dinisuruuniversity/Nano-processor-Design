library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Constants is

    constant clk_period      : time := 10 ns;
    constant clk_half_period : time := clk_period / 2;

    constant ADD_OP  : std_logic_vector(2 downto 0) := "000"; -- ADD  R0, R1  ?? R0 ? R1 + R0
    constant SUB_OP  : std_logic_vector(2 downto 0) := "001"; -- SUB  R0, R1  ?? R0 ? R1 - R2
    constant NEG_OP  : std_logic_vector(2 downto 0) := "010"; -- NEG  R0      ?? R0 ? 0  - R0
    constant MUL_OP  : std_logic_vector(2 downto 0) := "011"; -- MUL  R0, R1  ?? R0 ? R0 ? R1 (lower 4b)
    constant AND_OP  : std_logic_vector(2 downto 0) := "100"; -- AND  R0, R1  ?? R0 ? R1 AND R0
    constant OR_OP   : std_logic_vector(2 downto 0) := "101"; -- OR   R0, R1  ?? R0 ? R0 OR  R1
    constant MOVI_OP : std_logic_vector(2 downto 0) := "110"; -- MOVI R0, imm ?? R0 ? imm
    constant JZR_OP  : std_logic_vector(2 downto 0) := "111"; -- JZR  R0, adr ?? if R0=0: PC?adr

end package Constants;
