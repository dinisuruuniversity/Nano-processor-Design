----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 05:18:41 PM
-- Design Name: 
-- Module Name: RCA_3 - Behavioral
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

entity RCA_3 is
    Port ( A : in STD_LOGIC_VECTOR (2 downto 0);
           B : in STD_LOGIC_VECTOR (2 downto 0);
           C_in : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (2 downto 0);
           C_out : out STD_LOGIC);
end RCA_3;

architecture Behavioral of RCA_3 is
    constant N : integer := 3;
    
    component FA
        Port (
            A     : in  STD_LOGIC;
            B     : in  STD_LOGIC;
            C_in  : in  STD_LOGIC;
            S     : out STD_LOGIC;
            C_Out : out STD_LOGIC
        );
    end component;
    
signal Carry_Out : STD_LOGIC_VECTOR(N-1 downto 0);
signal Carry_In : STD_LOGIC_VECTOR(N-1 downto 0);

begin
 Carry_In(0) <= C_in;
        
        FAs : for i in 0 to N-1 generate
            FA_inst : FA 
                port map (
                    A => A(i), 
                    B => B(i),
                    C_in => Carry_In(i),
                    S => S(i), 
                    C_Out => Carry_Out(i)
                );
                
            last_carry: if i < N-1 generate
                Carry_In(i+1) <= Carry_Out(i);            
            end generate last_carry;
            
        end generate FAs;
     
        C_out <= Carry_Out(N-1);


end Behavioral;
