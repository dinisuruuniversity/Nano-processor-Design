library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package BusDefinitions is
   
    subtype std_logic_vector_3  is std_logic_vector(2 downto 0);
    subtype std_logic_vector_4  is std_logic_vector(3 downto 0);
    subtype std_logic_vector_8  is std_logic_vector(7 downto 0);
    subtype std_logic_vector_12 is std_logic_vector(11 downto 0);
    subtype std_logic_vector_13 is std_logic_vector(12 downto 0);  -- 13-bit instruction word


    type reg_array_8x4 is array (7 downto 0) of std_logic_vector_4;
    type mem_array_4x8 is array (3 downto 0) of std_logic_vector_8;

    
    subtype RegisterFile    is reg_array_8x4;          -- 8 x 4-bit registers
    subtype ProgramCounter  is std_logic_vector_3;     -- 3-bit PC (addresses 0-7)
    subtype InstructionWord is std_logic_vector_13;    -- 13-bit instruction (3-bit opcode)
    subtype DataBus         is std_logic_vector_4;     -- 4-bit data
    subtype RegisterSelect  is std_logic_vector_3;     -- 3-bit register address (R0-R7)

end package BusDefinitions;