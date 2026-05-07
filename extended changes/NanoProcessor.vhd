----------------------------------------------------------------------------------
-- Module Name:  NanoProcessor - Structural
-- Description:  Top-level for the 4-bit NanoProcessor with 14-bit instruction word.
--
--  Instruction Set (4-bit opcode, 11 instructions):
--    0000 ADD  Rd, Rs  ? Rd ? Rd + Rs
--    0001 SUB  Rd, Rs  ? Rd ? Rd - Rs
--    0010 NEG  Rd      ? Rd ? 0  - Rd
--    0011 MUL  Rd, Rs  ? Rd ? Rd × Rs (lower 4 bits)
--    0100 AND  Rd, Rs  ? Rd ? Rd AND Rs
--    0101 OR   Rd, Rs  ? Rd ? Rd OR Rs
--    0110 MOVI Rd, imm ? Rd ? imm4
--    0111 JZR  Rs, adr ? if Rs=0 : PC ? adr
--    1000 EQ   Rd, Rs  ? Equal flag
--    1001 GT   Rd, Rs  ? GreaterThan flag
--    1010 LT   Rd, Rs  ? LessThan flag
--
--  Board: Basys 3 (XC7A35T-1CPG236C)
--    Clk      ? W5   (100 MHz)
--    Reset    ? U18  (btnC, active-high)
--    LED(3:0) ? R7 value
--    LED(11)  ? Equal flag       (latched)
--    LED(12)  ? LessThan flag    (latched)
--    LED(13)  ? GreaterThan flag (latched)
--    LED(14)  ? Zero flag
--    LED(15)  ? Overflow flag
--    seg      ? 7-segment cathodes (R7 in hex, rightmost digit)
--    an       ? digit anodes
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

entity NanoProcessor is
    Port (
        Clk   : in  STD_LOGIC;
        Reset : in  STD_LOGIC;
        LED   : out STD_LOGIC_VECTOR(15 downto 0);
        seg   : out STD_LOGIC_VECTOR(6 downto 0);
        an    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end NanoProcessor;

architecture Structural of NanoProcessor is

    -----------------------------------------------------------------------
    -- Component Declarations
    -----------------------------------------------------------------------

    component Slow_Clk is
        Port ( Clk_in  : in  STD_LOGIC;
               Reset   : in  STD_LOGIC;
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
               ALU_Op                  : out STD_LOGIC_VECTOR(3 downto 0);
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
        Port ( A                : in  DataBus;
               B                : in  DataBus;
               Op               : in  STD_LOGIC_VECTOR(3 downto 0);
               Result           : out DataBus;
               Zero             : out STD_LOGIC;
               Overflow         : out STD_LOGIC;
               Equal_Flag       : out STD_LOGIC;
               LessThan_Flag    : out STD_LOGIC;
               GreaterThan_Flag : out STD_LOGIC );
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

    signal slow_clk_sig   : STD_LOGIC;

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
    signal id_alu_op      : STD_LOGIC_VECTOR(3 downto 0);
    signal id_immediate   : DataBus;
    signal id_load_select : STD_LOGIC;
    signal id_jump_enable : STD_LOGIC;
    signal id_jump_addr   : ProgramCounter;

    -- Register bank
    signal reg_outputs    : RegisterFile;
    signal reg_a_data     : DataBus;
    signal reg_b_data     : DataBus;

    -- ALU outputs
    signal alu_result     : DataBus;
    signal alu_zero       : STD_LOGIC;
    signal alu_overflow   : STD_LOGIC;

    -- Comparator flags (live, from Extended_ALU)
    signal alu_equal      : STD_LOGIC;
    signal alu_less       : STD_LOGIC;
    signal alu_greater    : STD_LOGIC;

    -- Write-back
    signal write_data     : DataBus;

    -- NEW: Opcode signal for latch control
    signal opcode_sig     : STD_LOGIC_VECTOR(3 downto 0);

    -- NEW: Latched comparator flags (hold value after comparison instruction)
    signal alu_equal_lat   : STD_LOGIC;
    signal alu_less_lat    : STD_LOGIC;
    signal alu_greater_lat : STD_LOGIC;
    signal alu_zero_lat : STD_LOGIC;

begin

    -----------------------------------------------------------------------
    -- 1. Slow Clock  (100 MHz ? ~1 Hz)
    -----------------------------------------------------------------------
    Slow_Clock_Inst : Slow_Clk
        port map (
            Clk_in  => Clk,
            Reset   => Reset,
            Clk_out => slow_clk_sig
        );

    -----------------------------------------------------------------------
    -- 2. Program Counter  (4 × D-FF, 4-bit address)
    -----------------------------------------------------------------------
    PC_Inst : Program_Counter
        port map (
            Nxt  => pc_next,
            Res  => Reset,
            Clk  => slow_clk_sig,
            Curr => pc_current
        );

    -----------------------------------------------------------------------
    -- 3. PC+1 Adder  (uses RCA_4 internally)
    -----------------------------------------------------------------------
    PC_Adder_Inst : Program_Counter_Adder
        port map (
            currAddress => pc_current,
            nxtAddress  => pc_plus1
        );

    -----------------------------------------------------------------------
    -- 4. Address Selector  (sequential vs jump)
    -----------------------------------------------------------------------
    Addr_Sel_Inst : Address_Selector
        port map (
            Sequential_Address => pc_plus1,
            Jump_Address       => id_jump_addr,
            Jump_Enable        => id_jump_enable,
            Selected_Address   => pc_next
        );

    -----------------------------------------------------------------------
    -- 5. Program ROM  (16 × 14-bit)
    -----------------------------------------------------------------------
    ROM_Inst : Program_ROM
        port map (
            address => pc_current,
            data    => instruction
        );

    -----------------------------------------------------------------------
    -- 6. Instruction Decoder
    -----------------------------------------------------------------------
    ID_Inst : Instruction_Decoder
        port map (
            Instruction             => instruction,
            Register_Value_For_Jump => reg_a_data,
            Register_Enable         => id_reg_enable,
            Register_Select_A       => id_reg_sel_a,
            Register_Select_B       => id_reg_sel_b,
            ALU_Op                  => id_alu_op,
            Immediate_Value         => id_immediate,
            Load_Select             => id_load_select,
            Jump_Enable             => id_jump_enable,
            Jump_Address            => id_jump_addr
        );

    -----------------------------------------------------------------------
    -- 7. Register Bank  (R0 hardwired to 0000)
    -----------------------------------------------------------------------
    RegBank_Inst : Register_Bank
        port map (
            Data             => write_data,
            Reset            => Reset,
            Reg_En           => id_reg_enable,
            Clock            => slow_clk_sig,
            Register_Outputs => reg_outputs
        );

    -----------------------------------------------------------------------
    -- 8. Operand-A MUX
    -----------------------------------------------------------------------
    MUX_A_Inst : MUX_8W_4B
        port map (
            input1 => reg_outputs(0),
            input2 => reg_outputs(1),
            input3 => reg_outputs(2),
            input4 => reg_outputs(3),
            input5 => reg_outputs(4),
            input6 => reg_outputs(5),
            input7 => reg_outputs(6),
            input8 => reg_outputs(7),
            slt    => id_reg_sel_a,
            output => reg_a_data
        );

    -----------------------------------------------------------------------
    -- 9. Operand-B MUX
    -----------------------------------------------------------------------
    MUX_B_Inst : MUX_8W_4B
        port map (
            input1 => reg_outputs(0),
            input2 => reg_outputs(1),
            input3 => reg_outputs(2),
            input4 => reg_outputs(3),
            input5 => reg_outputs(4),
            input6 => reg_outputs(5),
            input7 => reg_outputs(6),
            input8 => reg_outputs(7),
            slt    => id_reg_sel_b,
            output => reg_b_data
        );

    -----------------------------------------------------------------------
    -- 10. Extended ALU
    --     Instantiates Add_Sub_4_bit and Comparator_4_bit internally
    -----------------------------------------------------------------------
    ALU_Inst : Extended_ALU
        port map (
            A                => reg_a_data,
            B                => reg_b_data,
            Op               => id_alu_op,
            Result           => alu_result,
            Zero             => alu_zero,
            Overflow         => alu_overflow,
            Equal_Flag       => alu_equal,
            LessThan_Flag    => alu_less,
            GreaterThan_Flag => alu_greater
        );

    -----------------------------------------------------------------------
    -- 11. Load Selector  (write-back MUX)
    --     lSlt='1' ? ALU result
    --     lSlt='0' ? immediate value (MOVI)
    -----------------------------------------------------------------------
    LoadSel_Inst : Load_Selector
        port map (
            registerValue  => alu_result,
            immediateValue => id_immediate,
            lSlt           => id_load_select,
            outValue       => write_data
        );

    -----------------------------------------------------------------------
    -- 12. 7-Segment Display  (shows R7 value as hex)
    -----------------------------------------------------------------------
    LUT_Inst : LUT_16_7
        port map (
            address => reg_outputs(7),
            data    => seg
        );

    an <= "1110";  -- Rightmost digit active (active-low)

    -----------------------------------------------------------------------
    -- 13. Opcode Extraction for Latch Control
    --     Extracts bits [13:10] from current instruction
    -----------------------------------------------------------------------
    opcode_sig <= instruction(13 downto 10);

    -----------------------------------------------------------------------
    -- 14. Comparator Flag Latch
    --     Only latches flags during EQ/GT/LT instructions
    --     Prevents HALT (JZR R0 vs R0) from overwriting correct results
    --     Without this, comparator would show R0=R0=Equal at HALT
    -----------------------------------------------------------------------
process(slow_clk_sig, Reset)
    begin
        if Reset = '1' then
            alu_equal_lat   <= '0';
            alu_less_lat    <= '0';
            alu_greater_lat <= '0';
            alu_zero_lat    <= '0';   -- ADD THIS
        elsif rising_edge(slow_clk_sig) then
    
            -- Latch comparator flags only during EQ/GT/LT
            if opcode_sig = "1000" or   -- EQ
               opcode_sig = "1001" or   -- GT
               opcode_sig = "1010" then -- LT
                alu_equal_lat   <= alu_equal;
                alu_less_lat    <= alu_less;
                alu_greater_lat <= alu_greater;
            end if;
    
            -- Latch Zero flag only during real compute instructions
            if opcode_sig = "0000" or   -- ADD
               opcode_sig = "0001" or   -- SUB
               opcode_sig = "0010" or   -- NEG
               opcode_sig = "0011" or   -- MUL
               opcode_sig = "0100" or   -- AND
               opcode_sig = "0101" then -- OR
                alu_zero_lat <= alu_zero;
            end if;
    
        end if;
    end process;

    -----------------------------------------------------------------------
    -- 15. LED Outputs
    -----------------------------------------------------------------------
    LED(3  downto 0) <= reg_outputs(7);    -- R7 value (binary on LEDs)
    LED(10 downto 4) <= (others => '0');   -- unused LEDs off
    LED(11)          <= alu_equal_lat;     -- Equal flag    (latched) ?
    LED(12)          <= alu_less_lat;      -- LessThan flag (latched) ?
    LED(13)          <= alu_greater_lat;   -- GreaterThan flag (latched) ?
    LED(14)          <= alu_zero;          -- Zero flag (live)
    LED(15)          <= alu_overflow;      -- Overflow flag (live)

end Structural;