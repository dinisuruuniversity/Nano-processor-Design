----------------------------------------------------------------------------------
-- Testbench: Register_Bank_Sim  (REVISED)
-- Description:
--   Self-checking testbench for the 8 x 4-bit Register Bank.
--
--   KEY FIX vs original:
--     The original write_reg helper applied Data/Reg_En then called tick(),
--     which waited for the NEXT rising edge - meaning the register saw the
--     NEW inputs only AFTER the clock had already fired on the OLD values.
--     This caused all outputs to stay 0 in the waveform.
--
--     The fix: apply Data / Reg_En HALF a clock period BEFORE the rising
--     edge (i.e. at the falling edge), so they are fully stable when the
--     rising edge arrives.  The check is done AFTER the rising edge plus a
--     small propagation margin.
--
-- Tests covered:
--     1. Power-on state  : All registers output 0 before any clock edge
--     2. Reset           : Asynchronous reset clears all registers immediately
--     3. Zero register   : R0 always stays 0, even when Reg_En = "000"
--     4. Sequential write: Write unique values to R1-R7 one at a time
--     5. Persistence     : Previously written registers hold their value
--     6. Overwrite       : Writing a new value replaces the old one
--     7. Reset mid-run   : Reset in the middle of operation clears everything
--     8. Re-write after  : Registers work normally again after reset
--
-- Compile order:
--   1. BusDefinitions.vhd
--   2. Decoder_2_to_4.vhd
--   3. Decoder_3_to_8.vhd
--   4. Reg.vhd
--   5. Register_Bank.vhd
--   6. Register_Bank_Sim.vhd  (this file)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Register_Bank_Sim is
-- Testbench has no ports
end Register_Bank_Sim;

architecture Behavioral of Register_Bank_Sim is

    -----------------------------------------------------------------------
    -- Component under test
    -----------------------------------------------------------------------
    component Register_Bank
        Port (
            Data             : in  DataBus;
            Reset            : in  STD_LOGIC;
            Reg_En           : in  RegisterSelect;
            Clock            : in  STD_LOGIC;
            Register_Outputs : out RegisterFile
        );
    end component;

    -----------------------------------------------------------------------
    -- Stimulus signals
    -----------------------------------------------------------------------
    signal Data_TB   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal Reset_TB  : STD_LOGIC := '0';
    signal Reg_En_TB : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Clock_TB  : STD_LOGIC := '0';

    -- Observed outputs
    signal Register_Out_TB : RegisterFile;

    -----------------------------------------------------------------------
    -- Clock period
    -----------------------------------------------------------------------
    constant CLK_PERIOD : time := 100 ns;

    -----------------------------------------------------------------------
    -- Helper: convert 4-bit SLV to hex character for readable reports
    -----------------------------------------------------------------------
    function to_hex_char(v : STD_LOGIC_VECTOR(3 downto 0)) return character is
        variable n : integer;
    begin
        n := to_integer(unsigned(v));
        case n is
            when  0 => return '0';
            when  1 => return '1';
            when  2 => return '2';
            when  3 => return '3';
            when  4 => return '4';
            when  5 => return '5';
            when  6 => return '6';
            when  7 => return '7';
            when  8 => return '8';
            when  9 => return '9';
            when 10 => return 'A';
            when 11 => return 'B';
            when 12 => return 'C';
            when 13 => return 'D';
            when 14 => return 'E';
            when 15 => return 'F';
            when others => return '?';
        end case;
    end function;

    -----------------------------------------------------------------------
    -- Shared pass/fail counters
    -----------------------------------------------------------------------
    signal pass_count : integer := 0;
    signal fail_count : integer := 0;

begin

    -----------------------------------------------------------------------
    -- DUT instantiation
    -----------------------------------------------------------------------
    DUT : Register_Bank
        port map (
            Data             => Data_TB,
            Reset            => Reset_TB,
            Reg_En           => Reg_En_TB,
            Clock            => Clock_TB,
            Register_Outputs => Register_Out_TB
        );

    -----------------------------------------------------------------------
    -- Clock generator  (50 % duty cycle, 100 ns period)
    -----------------------------------------------------------------------
    Clock_TB <= not Clock_TB after CLK_PERIOD / 2;

    -----------------------------------------------------------------------
    -- Stimulus + self-checking process
    -----------------------------------------------------------------------
    stimulus : process

        -- ----------------------------------------------------------------
        -- wait_rising: block until the next rising edge then add a small
        -- propagation margin so outputs have settled.
        -- ----------------------------------------------------------------
        procedure wait_rising is
        begin
            wait until rising_edge(Clock_TB);
            wait for 10 ns;   -- propagation margin
        end procedure;

        -- ----------------------------------------------------------------
        -- write_reg: apply inputs at the FALLING edge (midway between two
        -- rising edges) so they are stable well before the next rising edge.
        -- After the rising edge fires, wait for propagation before returning.
        --
        --   Timeline:
        --     t0        : falling edge  ? Data_TB / Reg_En_TB updated HERE
        --     t0+50 ns  : rising edge   ? DUT latches the data
        --     t0+60 ns  : return        ? outputs are stable, ready to check
        -- ----------------------------------------------------------------
        procedure write_reg(
            reg  : in STD_LOGIC_VECTOR(2 downto 0);
            data : in STD_LOGIC_VECTOR(3 downto 0)) is
        begin
            -- Align to falling edge first so inputs arrive midway
            wait until falling_edge(Clock_TB);
            Reg_En_TB <= reg;
            Data_TB   <= data;
            -- Now wait for the very next rising edge + settle time
            wait_rising;
        end procedure;

        -- ----------------------------------------------------------------
        -- idle_cycles: let the clock run N cycles without writing anything.
        -- Reg_En is pointed at R0 so no GP register is accidentally enabled.
        -- ----------------------------------------------------------------
        procedure idle_cycles(n : integer) is
        begin
            Reg_En_TB <= "000";
            Data_TB   <= "0000";
            for i in 1 to n loop
                wait_rising;
            end loop;
        end procedure;

        -- ----------------------------------------------------------------
        -- check: compare one register output to the expected value.
        -- ----------------------------------------------------------------
        procedure check(
            reg_idx  : in integer;
            expected : in STD_LOGIC_VECTOR(3 downto 0);
            test_name: in string) is
        begin
            if Register_Out_TB(reg_idx) = expected then
                report "[PASS] " & test_name &
                       "  R" & integer'image(reg_idx) &
                       " = 0x" & to_hex_char(Register_Out_TB(reg_idx)) &
                       "  (expected 0x" & to_hex_char(expected) & ")"
                    severity note;
                pass_count <= pass_count + 1;
            else
                report "[FAIL] " & test_name &
                       "  R" & integer'image(reg_idx) &
                       " = 0x" & to_hex_char(Register_Out_TB(reg_idx)) &
                       "  (expected 0x" & to_hex_char(expected) & ")"
                    severity error;
                fail_count <= fail_count + 1;
            end if;
        end procedure;

        -- ----------------------------------------------------------------
        -- check_all: check all 8 registers at once.
        -- ----------------------------------------------------------------
        procedure check_all(
            exp      : in RegisterFile;
            test_name: in string) is
        begin
            for i in 0 to 7 loop
                check(i, exp(i), test_name);
            end loop;
        end procedure;

        variable expected : RegisterFile;

    begin
        --------------------------------------------------------------------------
        -- 1. POWER-ON STATE
        --    No clock edges yet; registers initialise to 0.
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 1 : Power-on / initial state"      severity note;
        report "========================================" severity note;

        wait for 5 ns;
        for i in 0 to 7 loop
            expected(i) := "0000";
        end loop;
        check_all(expected, "Power-on");

        --------------------------------------------------------------------------
        -- 2. ASYNCHRONOUS RESET (before any clock edge)
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 2 : Asynchronous reset"            severity note;
        report "========================================" severity note;

        Reset_TB <= '1';
        wait for 20 ns;
        for i in 0 to 7 loop
            expected(i) := "0000";
        end loop;
        check_all(expected, "Async Reset");
        Reset_TB <= '0';
        wait for 10 ns;

        --------------------------------------------------------------------------
        -- 3. ZERO REGISTER (R0 must never store a non-zero value)
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 3 : R0 is always zero"             severity note;
        report "========================================" severity note;

        write_reg("000", "1111");   -- try to write 0xF to R0
        check(0, "0000", "R0 zero-lock write-attempt 1");

        write_reg("000", "1010");   -- try again with 0xA
        check(0, "0000", "R0 zero-lock write-attempt 2");

        --------------------------------------------------------------------------
        -- 4. SEQUENTIAL WRITE R1 -> R7
        --    Inputs are applied at the falling edge so they are stable before
        --    the rising edge that latches them.  This is what makes the
        --    non-zero values appear in the waveform viewer.
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 4 : Sequential write R1-R7"        severity note;
        report "========================================" severity note;

        write_reg("001", "0001");   -- R1 <- 0x1
        check(1, "0001", "Write R1=0x1");
        check(0, "0000", "R0 still 0 after R1 write");

        write_reg("010", "0010");   -- R2 <- 0x2
        check(2, "0010", "Write R2=0x2");
        check(1, "0001", "R1 holds value after R2 write");

        write_reg("011", "0100");   -- R3 <- 0x4
        check(3, "0100", "Write R3=0x4");
        check(2, "0010", "R2 holds value after R3 write");

        write_reg("100", "1000");   -- R4 <- 0x8
        check(4, "1000", "Write R4=0x8");
        check(3, "0100", "R3 holds value after R4 write");

        write_reg("101", "1010");   -- R5 <- 0xA
        check(5, "1010", "Write R5=0xA");
        check(4, "1000", "R4 holds value after R5 write");

        write_reg("110", "1100");   -- R6 <- 0xC
        check(6, "1100", "Write R6=0xC");
        check(5, "1010", "R5 holds value after R6 write");

        write_reg("111", "1111");   -- R7 <- 0xF
        check(7, "1111", "Write R7=0xF");
        check(6, "1100", "R6 holds value after R7 write");

        --------------------------------------------------------------------------
        -- 5. PERSISTENCE  - idle for 4 cycles, ensure nothing drifts
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 5 : Persistence (no write)"        severity note;
        report "========================================" severity note;

        idle_cycles(4);

        expected(0) := "0000";
        expected(1) := "0001";
        expected(2) := "0010";
        expected(3) := "0100";
        expected(4) := "1000";
        expected(5) := "1010";
        expected(6) := "1100";
        expected(7) := "1111";
        check_all(expected, "Persistence");

        --------------------------------------------------------------------------
        -- 6. OVERWRITE - write a new value to an already-populated register
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 6 : Overwrite existing register"   severity note;
        report "========================================" severity note;

        write_reg("011", "0111");   -- R3: 0x4 -> 0x7
        check(3, "0111", "Overwrite R3 0x4->0x7");
        check(2, "0010", "R2 unaffected by R3 overwrite");
        check(4, "1000", "R4 unaffected by R3 overwrite");

        write_reg("101", "0101");   -- R5: 0xA -> 0x5
        check(5, "0101", "Overwrite R5 0xA->0x5");

        --------------------------------------------------------------------------
        -- 7. MID-RUN RESET  - assert reset with live data in all registers
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 7 : Mid-run asynchronous reset"    severity note;
        report "========================================" severity note;

        Data_TB  <= "1111";
        Reset_TB <= '1';
        wait for 20 ns;          -- reset fires asynchronously (no clock needed)

        for i in 0 to 7 loop
            expected(i) := "0000";
        end loop;
        check_all(expected, "Mid-run Reset");

        Reset_TB <= '0';
        wait for CLK_PERIOD;     -- let the clock run a cycle before re-writing

        --------------------------------------------------------------------------
        -- 8. RE-WRITE AFTER RESET - bank must be fully functional post-reset
        --------------------------------------------------------------------------
        report "========================================" severity note;
        report " TEST 8 : Re-write after reset"          severity note;
        report "========================================" severity note;

        write_reg("001", "0001");   -- R1 <- 0x1
        write_reg("010", "0011");   -- R2 <- 0x3
        write_reg("011", "0111");   -- R3 <- 0x7
        write_reg("100", "1111");   -- R4 <- 0xF
        write_reg("101", "1010");   -- R5 <- 0xA
        write_reg("110", "1100");   -- R6 <- 0xC
        write_reg("111", "1110");   -- R7 <- 0xE

        expected(0) := "0000";
        expected(1) := "0001";
        expected(2) := "0011";
        expected(3) := "0111";
        expected(4) := "1111";
        expected(5) := "1010";
        expected(6) := "1100";
        expected(7) := "1110";
        check_all(expected, "Post-reset re-write");

        -- Hold outputs visible for a few cycles so the waveform is readable
        idle_cycles(3);

        --------------------------------------------------------------------------
        -- SUMMARY
        --------------------------------------------------------------------------
        wait for CLK_PERIOD;
        report "========================================" severity note;
        report " SIMULATION COMPLETE"                    severity note;
        report " PASSED : " & integer'image(pass_count)  severity note;
        report " FAILED : " & integer'image(fail_count)  severity note;
        report "========================================"  severity note;

        if fail_count = 0 then
            report "ALL TESTS PASSED" severity note;
        else
            report "SOME TESTS FAILED - see [FAIL] lines above" severity failure;
        end if;

        wait;   -- stop simulation
    end process;

end Behavioral;