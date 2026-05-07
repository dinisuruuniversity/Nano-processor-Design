library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Constants is

    constant clk_period      : time := 10 ns;
    constant clk_half_period : time := clk_period / 2;

    constant ADD_OP  : std_logic_vector(3 downto 0) := "0000"; -- ADD  R0, R1  ?? R0 ? R1 + R0
    constant SUB_OP  : std_logic_vector(3 downto 0) := "0001"; -- SUB  R0, R1  ?? R0 ? R1 - R2
    constant NEG_OP  : std_logic_vector(3 downto 0) := "0010"; -- NEG  R0      ?? R0 ? 0  - R0
    constant MUL_OP  : std_logic_vector(3 downto 0) := "0011"; -- MUL  R0, R1  ?? R0 ? R0 ? R1 (lower 4b)
    constant AND_OP  : std_logic_vector(3 downto 0) := "0100"; -- AND  R0, R1  ?? R0 ? R1 AND R0
    constant OR_OP   : std_logic_vector(3 downto 0) := "0101"; -- OR   R0, R1  ?? R0 ? R0 OR  R1
    constant MOVI_OP : std_logic_vector(3 downto 0) := "0110"; -- MOVI R0, imm ?? R0 ? imm
    constant JZR_OP  : std_logic_vector(3 downto 0) := "0111"; -- JZR  R0, adr ?? if R0=0: PC?adr
    constant EQ_OP   : std_logic_vector(3 downto 0) := "1000"; -- EQUAL Rd, Rs
    constant GT_OP   : std_logic_vector(3 downto 0) := "1001"; -- GREATER THAN
    constant LT_OP   : std_logic_vector(3 downto 0) := "1010"; -- LESS THAN


end package Constants;
