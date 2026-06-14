----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 02:14:51 PM
-- Design Name: 
-- Module Name: Load_Selector - Behavioral
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

entity Load_Selector is
    port(
        registerValue   : in DataBus;
        immediateValue   : in DataBus;
        lSlt           : in STD_LOGIC;
        outValue        : out DataBus
    );
end Load_Selector;

architecture Behavioral of Load_Selector is

component MUX_2W_4B
    port(
        input1      : in STD_LOGIC_VECTOR(3 downto 0);
        input2      : in STD_LOGIC_VECTOR(3 downto 0);
        slt         : in STD_LOGIC;
        output      : out STD_LOGIC_VECTOR(3 downto 0)
    );
end component;

begin

   DataSourceMux : MUX_2W_4B Port Map(
        input1 => immediateValue, -- when lSlt = '0', use immediateValue
        input2 => registerValue, -- when lSlt = '1', use registerValue
        slt => lSlt,
        output => outValue
   );

end Behavioral;
