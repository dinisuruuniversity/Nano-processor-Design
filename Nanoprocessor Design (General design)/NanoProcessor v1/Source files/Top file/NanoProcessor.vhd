----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

entity NanoProcessor is
    Port (
        Clk   : in  STD_LOGIC;                       -- 100 MHz board clock
        Reset : in  STD_LOGIC;                        -- Active-high reset (btnC)
        LED   : out STD_LOGIC_VECTOR(3 downto 0);    -- Result: R1 value on LEDs
        seg   : out STD_LOGIC_VECTOR(6 downto 0);    -- 7-segment cathodes
        an    : out STD_LOGIC_VECTOR(3 downto 0)     -- 7-segment anodes
    );
end NanoProcessor;

architecture Structural of NanoProcessor is

    -----------------------------------------------------------------------
    -- Component Declarations
    -----------------------------------------------------------------------

    component Slow_Clk is
        Port (
            Clk_in  : in  STD_LOGIC;
            Clk_out : out STD_LOGIC
        );
    end component;

    component Program_Counter is
        Port (
            Nxt  : in  ProgramCounter;
            Res  : in  STD_LOGIC;
            Clk  : in  STD_LOGIC;
            Curr : out ProgramCounter
        );
    end component;

    component Program_Counter_Adder is
        Port (
            currAddress : in  ProgramCounter;
            nxtAddress  : out ProgramCounter
        );
    end component;

    component Program_ROM is
        Port (
            address : in  ProgramCounter;
            data    : out InstructionWord
        );
    end component;

    component Instruction_Decoder is
        Port (
            Instruction             : in  InstructionWord;
            Register_Value_For_Jump : in  DataBus;
            Register_Enable         : out RegisterSelect;
            Register_Select_A       : out RegisterSelect;
            Register_Select_B       : out RegisterSelect;
            Operation_Select        : out STD_LOGIC;
            Immediate_Value         : out DataBus;
            Jump_Enable             : out STD_LOGIC;
            Jump_Address            : out ProgramCounter;
            Load_Select             : out STD_LOGIC
        );
    end component;

    component Address_Selector is
        Port (
            Sequential_Address : in  ProgramCounter;
            Jump_Address       : in  ProgramCounter;
            Jump_Enable        : in  STD_LOGIC;
            Selected_Address   : out ProgramCounter
        );
    end component;

    component Register_Bank is
        Port (
            Data             : in  DataBus;
            Reset            : in  STD_LOGIC;
            Reg_En           : in  RegisterSelect;
            Clock            : in  STD_LOGIC;
            Register_Outputs : out RegisterFile
        );
    end component;

    component MUX_8W_4B is
        Port (
            input1 : in  STD_LOGIC_VECTOR(3 downto 0);
            input2 : in  STD_LOGIC_VECTOR(3 downto 0);
            input3 : in  STD_LOGIC_VECTOR(3 downto 0);
            input4 : in  STD_LOGIC_VECTOR(3 downto 0);
            input5 : in  STD_LOGIC_VECTOR(3 downto 0);
            input6 : in  STD_LOGIC_VECTOR(3 downto 0);
            input7 : in  STD_LOGIC_VECTOR(3 downto 0);
            input8 : in  STD_LOGIC_VECTOR(3 downto 0);
            slt    : in  STD_LOGIC_VECTOR(2 downto 0);
            output : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component Add_Sub_4_bit is
        Port (
            A_AS     : in  STD_LOGIC_VECTOR(3 downto 0);
            B_AS     : in  STD_LOGIC_VECTOR(3 downto 0);
            CTRL     : in  STD_LOGIC;
            S_AS     : out STD_LOGIC_VECTOR(3 downto 0);
            Zero     : out STD_LOGIC;
            OverFlow : out STD_LOGIC
        );
    end component;

    component Load_Selector is
        Port (
            registerValue  : in  DataBus;
            immediateValue : in  DataBus;
            lSlt           : in  STD_LOGIC;
            outValue       : out DataBus
        );
    end component;

    component LUT_16_7 is
        Port (
            address : in  DataBus;
            data    : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -----------------------------------------------------------------------
    -- Internal Signal Declarations
    -----------------------------------------------------------------------

    -- Clock
    signal slow_clk_sig          : STD_LOGIC;

    -- Program Counter datapath
    signal pc_current         : ProgramCounter;   -- Current PC value
    signal pc_plus1           : ProgramCounter;   -- PC + 1
    signal pc_next            : ProgramCounter;   -- Selected next PC (to FF input)

    -- ROM output
    signal instruction        : InstructionWord;  -- 12-bit instruction word

    -- Instruction Decoder outputs
    signal id_reg_enable      : RegisterSelect;   -- Destination register address
    signal id_reg_sel_a       : RegisterSelect;   -- Operand A register select
    signal id_reg_sel_b       : RegisterSelect;   -- Operand B register select
    signal id_op_select       : STD_LOGIC;        -- 0=ADD, 1=SUB
    signal id_immediate       : DataBus;          -- 4-bit immediate value
    signal id_jump_enable     : STD_LOGIC;        -- Jump enable flag
    signal id_jump_address    : ProgramCounter;   -- Jump target address
    signal id_load_select     : STD_LOGIC;        -- 0=immediate, 1=ALU result

    -- Register Bank outputs (all 8 registers exposed)
    signal reg_outputs        : RegisterFile;     -- reg_outputs(0)..reg_outputs(7)

    -- Register MUX outputs
    signal reg_a_data         : DataBus;          -- Value of operand register A
    signal reg_b_data         : DataBus;          -- Value of operand register B

    -- ALU outputs
    signal alu_result         : DataBus;          -- 4-bit result
    signal alu_zero           : STD_LOGIC;        -- '1' when result = 0
    signal alu_overflow       : STD_LOGIC;        -- carry-out of bit 3

    -- Write-back data (immediate or ALU result)
    signal write_data         : DataBus;

begin

    -----------------------------------------------------------------------
    -- 1. Slow Clock Divider
    --    100 MHz → ~1 Hz (toggles every 50,000,000 cycles)
    -----------------------------------------------------------------------
    Slow_Clock_Inst : Slow_Clk
        port map (
            Clk_in  => Clk,
            Clk_out => slow_clk_sig
        );

    -----------------------------------------------------------------------
    -- 2. Program Counter Register  (3 × D-FF)
    --    Loads pc_next on every rising edge of slow_clk.
    --    Reset clears PC to 000.
    -----------------------------------------------------------------------
    PC_Inst : Program_Counter
        port map (
            Nxt  => pc_next,
            Res  => Reset,
            Clk  => slow_clk_sig,
            Curr => pc_current
        );

    -----------------------------------------------------------------------
    -- 3. PC+1 Adder  (3-bit RCA wrapping increment)
    -----------------------------------------------------------------------
    PC_Adder_Inst : Program_Counter_Adder
        port map (
            currAddress => pc_current,
            nxtAddress  => pc_plus1
        );

    -----------------------------------------------------------------------
    -- 4. Address Selector MUX
    --    Selects between sequential (pc_plus1) and jump address.
    -----------------------------------------------------------------------
    Addr_Sel_Inst : Address_Selector
        port map (
            Sequential_Address => pc_plus1,
            Jump_Address       => id_jump_address,
            Jump_Enable        => id_jump_enable,
            Selected_Address   => pc_next
        );

    -----------------------------------------------------------------------
    -- 5. Program ROM  (8 × 12-bit combinational read)
    -----------------------------------------------------------------------
    ROM_Inst : Program_ROM
        port map (
            address => pc_current,
            data    => instruction
        );

    -----------------------------------------------------------------------
    -- 6. Instruction Decoder
    --    Decodes 12-bit instruction → all control signals.
    --    Register_Value_For_Jump is wired to reg_a_data (the value of
    --    instruction[9:7] register) so JZR can evaluate the condition.
    -----------------------------------------------------------------------
    ID_Inst : Instruction_Decoder
        port map (
            Instruction             => instruction,
            Register_Value_For_Jump => reg_a_data,
            Register_Enable         => id_reg_enable,
            Register_Select_A       => id_reg_sel_a,
            Register_Select_B       => id_reg_sel_b,
            Operation_Select        => id_op_select,
            Immediate_Value         => id_immediate,
            Jump_Enable             => id_jump_enable,
            Jump_Address            => id_jump_address,
            Load_Select             => id_load_select
        );

    -----------------------------------------------------------------------
    -- 7. Register Bank  (8 × 4-bit registers, R0 hardwired to 0)
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
    -- 8. Operand-A MUX  (8-way, 4-bit)
    --    Selects one register value based on Register_Select_A.
    -----------------------------------------------------------------------
    MUX_A_Inst : MUX_8W_4B
        port map (
            input1 => reg_outputs(0),   -- R0 (always 0000)
            input2 => reg_outputs(1),   -- R1
            input3 => reg_outputs(2),   -- R2
            input4 => reg_outputs(3),   -- R3
            input5 => reg_outputs(4),   -- R4
            input6 => reg_outputs(5),   -- R5
            input7 => reg_outputs(6),   -- R6
            input8 => reg_outputs(7),   -- R7
            slt    => id_reg_sel_a,
            output => reg_a_data
        );

    -----------------------------------------------------------------------
    -- 9. Operand-B MUX  (8-way, 4-bit)
    --    Selects one register value based on Register_Select_B.
    -----------------------------------------------------------------------
    MUX_B_Inst : MUX_8W_4B
        port map (
            input1 => reg_outputs(0),   -- R0
            input2 => reg_outputs(1),   -- R1
            input3 => reg_outputs(2),   -- R2
            input4 => reg_outputs(3),   -- R3
            input5 => reg_outputs(4),   -- R4
            input6 => reg_outputs(5),   -- R5
            input7 => reg_outputs(6),   -- R6
            input8 => reg_outputs(7),   -- R7
            slt    => id_reg_sel_b,
            output => reg_b_data
        );

    -----------------------------------------------------------------------
    -- 10. 4-bit Add/Subtract Unit
    --     CTRL='0' → ADD,  CTRL='1' → SUB (two's complement via XOR+carry)
    -----------------------------------------------------------------------
    ALU_Inst : Add_Sub_4_bit
        port map (
            A_AS     => reg_a_data,
            B_AS     => reg_b_data,
            CTRL     => id_op_select,
            S_AS     => alu_result,
            Zero     => alu_zero,
            OverFlow => alu_overflow
        );

    -----------------------------------------------------------------------
    -- 11. Load Selector (Write-Back MUX)
    --     lSlt='0' → write immediate value (MOVI)
    --     lSlt='1' → write ALU result     (ADD / NEG)
    -----------------------------------------------------------------------
    LoadSel_Inst : Load_Selector
        port map (
            registerValue  => alu_result,
            immediateValue => id_immediate,
            lSlt           => id_load_select,
            outValue       => write_data
        );

    -----------------------------------------------------------------------
    -- 12. 7-Segment Display LUT  (16-entry, drives rightmost digit)
    --     Displays R1 result as a hex digit on the 7-segment display.
    -----------------------------------------------------------------------
    LUT_Inst : LUT_16_7
        port map (
            address => reg_outputs(7),   -- show R7
            data    => seg
        );

    -- Enable only the rightmost digit (active-low anodes on Basys 3)
    an <= "1110";

    -----------------------------------------------------------------------
    -- 13. LED output  (R7 value → 4 rightmost LEDs)
    -----------------------------------------------------------------------
    LED <= reg_outputs(7);

end Structural;
