----------------------------------------------------------------------------------
-- Module Name:  NanoProcessor - Structural
-- Description:  Top-level for the 4-bit NanoProcessor with 13-bit instruction word.
--
--  Instruction Set (3-bit opcode, 8 instructions):
--    000 ADD  Rd, Rs  → Rd ← Rd + Rs
--    001 SUB  Rd, Rs  → Rd ← Rd - Rs
--    010 NEG  Rd      → Rd ← 0  - Rd
--    011 MUL  Rd, Rs  → Rd ← Rd × Rs (lower 4 bits)
--    100 AND  Rd, Rs  → Rd ← Rd AND Rs
--    101 OR   Rd, Rs  → Rd ← Rd OR Rs
--    110 MOVI Rd, imm → Rd ← imm4
--    111 JZR  Rs, adr → if Rs=0 : PC ← adr
--
--  Board: Basys 3 (XC7A35T-1CPG236C)
--    Clk     → W5   (100 MHz)
--    Reset   → U18  (btnC, active-high)
--    LED(3:0)→ R1 value
--    LED(4)  → Zero flag
--    LED(5)  → Overflow / MUL overflow flag
--    seg     → 7-segment cathodes (R1 in hex, rightmost digit)
--    an      → digit anodes
--
--  Compile order:
--    1.  Packages/BusDefinitions.vhd
--    2.  Packages/constants.vhd
--    3.  3-bit Adder/HA.vhd
--    4.  3-bit Adder/FA.vhd
--    5.  3-bit Adder/RCA_3.vhd
--    6.  Decoders/Decoder_2_to_4.vhd
--    7.  Decoders/Decoder_3_to_8.vhd
--    8.  D Flip Flop/D_FF.vhd
--    9.  Register Bank/Reg.vhd
--    10. Register Bank/Register_Bank.vhd
--    11. MUX/MUX_2W_3B.vhd
--    12. MUX/MUX_2W_4B.vhd
--    13. MUX/MUX_8W_4B.vhd
--    14. Program Counter/Program_Counter.vhd
--    15. Program Counter Adder/Program_Counter_Adder.vhd
--    16. Adress_Selector/Address_selector.vhd
--    17. Load_Selector/Load_Selector.vhd
--    18. 4-bit Add_Subtract unit/Extended_ALU.vhd
--    19. Instruction Decoder/Instruction_Decoder.vhd
--    20. Look up tables/LUT_16_7.vhd
--    21. Slow_Clock/Slow_Clk.vhd
--    22. Program Rom/Program_ROM.vhd
--    23. Top file/NanoProcessor.vhd   ← this file
--
--  NOTE: Do NOT add Register Bank/BusDefinitions.vhd — use Packages/ version only.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

entity NanoProcessor is
    Port (
        Clk   : in  STD_LOGIC;                     -- 100 MHz board clock
        Reset : in  STD_LOGIC;                      -- Active-high reset (btnC)
        LED   : out STD_LOGIC_VECTOR(5 downto 0);  -- [3:0]=R1, [4]=Zero, [5]=Overflow
        seg   : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-segment cathodes
        an    : out STD_LOGIC_VECTOR(3 downto 0)   -- 7-segment anodes
    );
end NanoProcessor;

architecture Structural of NanoProcessor is

    -----------------------------------------------------------------------
    -- Component Declarations
    -----------------------------------------------------------------------

    component Slow_Clk is
        Port ( Clk_in  : in  STD_LOGIC;
               Clk_out : out STD_LOGIC );
    end component;

    component Program_Counter is
        Port ( Nxt  : in  ProgramCounter;
               Res  : in  STD_LOGIC;
               Clk  : in  STD_LOGIC;
               Curr : out ProgramCounter );
    end component;

    component Program_Counter_Adder is
        Port ( currAddress : in  ProgramCounter;
               nxtAddress  : out ProgramCounter );
    end component;

    component Address_Selector is
        Port ( Sequential_Address : in  ProgramCounter;
               Jump_Address       : in  ProgramCounter;
               Jump_Enable        : in  STD_LOGIC;
               Selected_Address   : out ProgramCounter );
    end component;

    component Program_ROM is
        Port ( address : in  ProgramCounter;
               data    : out InstructionWord );
    end component;

    component Instruction_Decoder is
        Port ( Instruction             : in  InstructionWord;
               Register_Value_For_Jump : in  DataBus;
               Register_Enable         : out RegisterSelect;
               Register_Select_A       : out RegisterSelect;
               Register_Select_B       : out RegisterSelect;
               ALU_Op                  : out STD_LOGIC_VECTOR(2 downto 0);
               Immediate_Value         : out DataBus;
               Load_Select             : out STD_LOGIC;
               Jump_Enable             : out STD_LOGIC;
               Jump_Address            : out ProgramCounter );
    end component;

    component Register_Bank is
        Port ( Data             : in  DataBus;
               Reset            : in  STD_LOGIC;
               Reg_En           : in  RegisterSelect;
               Clock            : in  STD_LOGIC;
               Register_Outputs : out RegisterFile );
    end component;

    component MUX_8W_4B is
        Port ( input1 : in  STD_LOGIC_VECTOR(3 downto 0);
               input2 : in  STD_LOGIC_VECTOR(3 downto 0);
               input3 : in  STD_LOGIC_VECTOR(3 downto 0);
               input4 : in  STD_LOGIC_VECTOR(3 downto 0);
               input5 : in  STD_LOGIC_VECTOR(3 downto 0);
               input6 : in  STD_LOGIC_VECTOR(3 downto 0);
               input7 : in  STD_LOGIC_VECTOR(3 downto 0);
               input8 : in  STD_LOGIC_VECTOR(3 downto 0);
               slt    : in  STD_LOGIC_VECTOR(2 downto 0);
               output : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;

    component Extended_ALU is
        Port ( A        : in  DataBus;
               B        : in  DataBus;
               Op       : in  STD_LOGIC_VECTOR(2 downto 0);
               Result   : out DataBus;
               Zero     : out STD_LOGIC;
               Overflow : out STD_LOGIC );
    end component;

    component Load_Selector is
        Port ( registerValue  : in  DataBus;
               immediateValue : in  DataBus;
               lSlt           : in  STD_LOGIC;
               outValue       : out DataBus );
    end component;

    component LUT_16_7 is
        Port ( address : in  DataBus;
               data    : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;

    -----------------------------------------------------------------------
    -- Internal Signals
    -----------------------------------------------------------------------

    signal slow_clk       : STD_LOGIC;

    -- PC datapath
    signal pc_current     : ProgramCounter;
    signal pc_plus1       : ProgramCounter;
    signal pc_next        : ProgramCounter;

    -- Instruction
    signal instruction    : InstructionWord;

    -- Decoder outputs
    signal id_reg_enable  : RegisterSelect;
    signal id_reg_sel_a   : RegisterSelect;
    signal id_reg_sel_b   : RegisterSelect;
    signal id_alu_op      : STD_LOGIC_VECTOR(2 downto 0);
    signal id_immediate   : DataBus;
    signal id_load_select : STD_LOGIC;
    signal id_jump_enable : STD_LOGIC;
    signal id_jump_addr   : ProgramCounter;

    -- Register bank
    signal reg_outputs    : RegisterFile;
    signal reg_a_data     : DataBus;
    signal reg_b_data     : DataBus;

    -- ALU
    signal alu_result     : DataBus;
    signal alu_zero       : STD_LOGIC;
    signal alu_overflow   : STD_LOGIC;

    -- Write-back
    signal write_data     : DataBus;

begin

    -----------------------------------------------------------------------
    -- 1. Slow Clock  (100 MHz → ~1 Hz)
    -----------------------------------------------------------------------
    Slow_Clock_Inst : Slow_Clk
        port map ( Clk_in => Clk, Clk_out => slow_clk );

    -----------------------------------------------------------------------
    -- 2. Program Counter  (3 × D-FF)
    -----------------------------------------------------------------------
    PC_Inst : Program_Counter
        port map ( Nxt  => pc_next,
                   Res  => Reset,
                   Clk  => slow_clk,
                   Curr => pc_current );

    -----------------------------------------------------------------------
    -- 3. PC+1 Adder
    -----------------------------------------------------------------------
    PC_Adder_Inst : Program_Counter_Adder
        port map ( currAddress => pc_current,
                   nxtAddress  => pc_plus1 );

    -----------------------------------------------------------------------
    -- 4. Address Selector  (sequential vs jump)
    -----------------------------------------------------------------------
    Addr_Sel_Inst : Address_Selector
        port map ( Sequential_Address => pc_plus1,
                   Jump_Address       => id_jump_addr,
                   Jump_Enable        => id_jump_enable,
                   Selected_Address   => pc_next );

    -----------------------------------------------------------------------
    -- 5. Program ROM  (8 × 13-bit)
    -----------------------------------------------------------------------
    ROM_Inst : Program_ROM
        port map ( program_counter => pc_current,
                   instruction_out => instruction );

    -----------------------------------------------------------------------
    -- 6. Instruction Decoder
    -----------------------------------------------------------------------
    ID_Inst : Instruction_Decoder
        port map ( Instruction             => instruction,
                   Register_Value_For_Jump => reg_a_data,
                   Register_Enable         => id_reg_enable,
                   Register_Select_A       => id_reg_sel_a,
                   Register_Select_B       => id_reg_sel_b,
                   ALU_Op                  => id_alu_op,
                   Immediate_Value         => id_immediate,
                   Load_Select             => id_load_select,
                   Jump_Enable             => id_jump_enable,
                   Jump_Address            => id_jump_addr );

    -----------------------------------------------------------------------
    -- 7. Register Bank  (R0 hardwired to 0000)
    -----------------------------------------------------------------------
    RegBank_Inst : Register_Bank
        port map ( Data             => write_data,
                   Reset            => Reset,
                   Reg_En           => id_reg_enable,
                   Clock            => slow_clk,
                   Register_Outputs => reg_outputs );

    -----------------------------------------------------------------------
    -- 8. Operand-A MUX  (selects register for first operand)
    -----------------------------------------------------------------------
    MUX_A_Inst : MUX_8W_4B
        port map ( input1 => reg_outputs(0),
                   input2 => reg_outputs(1),
                   input3 => reg_outputs(2),
                   input4 => reg_outputs(3),
                   input5 => reg_outputs(4),
                   input6 => reg_outputs(5),
                   input7 => reg_outputs(6),
                   input8 => reg_outputs(7),
                   slt    => id_reg_sel_a,
                   output => reg_a_data );

    -----------------------------------------------------------------------
    -- 9. Operand-B MUX  (selects register for second operand)
    -----------------------------------------------------------------------
    MUX_B_Inst : MUX_8W_4B
        port map ( input1 => reg_outputs(0),
                   input2 => reg_outputs(1),
                   input3 => reg_outputs(2),
                   input4 => reg_outputs(3),
                   input5 => reg_outputs(4),
                   input6 => reg_outputs(5),
                   input7 => reg_outputs(6),
                   input8 => reg_outputs(7),
                   slt    => id_reg_sel_b,
                   output => reg_b_data );

    -----------------------------------------------------------------------
    -- 10. Extended ALU
    --     Handles: ADD, SUB, NEG, MUL, AND, OR
    --     Op directly receives the 3-bit opcode from the decoder
    -----------------------------------------------------------------------
    ALU_Inst : Extended_ALU
        port map ( A        => reg_a_data,
                   B        => reg_b_data,
                   Op       => id_alu_op,
                   Result   => alu_result,
                   Zero     => alu_zero,
                   Overflow => alu_overflow );

    -----------------------------------------------------------------------
    -- 11. Load Selector  (write-back MUX)
    --     lSlt='0' → MOVI: write immediate value
    --     lSlt='1' → ALU instruction: write ALU result
    -----------------------------------------------------------------------
    LoadSel_Inst : Load_Selector
        port map ( registerValue  => alu_result,
                   immediateValue => id_immediate,
                   lSlt           => id_load_select,
                   outValue       => write_data );

    -----------------------------------------------------------------------
    -- 12. 7-Segment Display  (shows R1 value as hex)
    -----------------------------------------------------------------------
    LUT_Inst : LUT_16_7
        port map ( address => reg_outputs(1),
                   data    => seg );

    an <= "1110";  -- Rightmost digit active (active-low)

    -----------------------------------------------------------------------
    -- 13. LED outputs
    -----------------------------------------------------------------------
    LED(3 downto 0) <= reg_outputs(1);  -- R1 result
    LED(4)          <= alu_zero;         -- Zero flag
    LED(5)          <= alu_overflow;     -- Overflow / MUL overflow flag

end Structural;
