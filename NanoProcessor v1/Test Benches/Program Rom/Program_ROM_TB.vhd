library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;
use work.Constants.all;

entity Program_ROM_TB is
end Program_ROM_TB;

architecture Behavioral of Program_ROM_TB is

    component Program_ROM is
        port(
            program_counter : in  ProgramCounter;
            instruction_out : out InstructionWord
        );
    end component;

    signal tb_program_counter : ProgramCounter := (others => '0');
    signal tb_instruction_out : InstructionWord;

    type expected_rom_type is array (0 to 7) of std_logic_vector(11 downto 0);
    constant EXPECTED_ROM : expected_rom_type := (
        "101110000101",  -- 0: MOVI R7, 5
        "101100000011",  -- 1: MOVI R6, 3
        "001111100000",  -- 2: ADD  R7, R6
        "011101100000",  -- 3: NEG  R6, R6
        "001111100000",  -- 4: ADD  R7, R6
        "011111110000",  -- 5: NEG  R7, R7
        "001101110000",  -- 6: ADD  R6, R7
        "111110000000"   -- 7: JZR  R7, 0
    );

    constant PROP_DELAY : time := 10 ns;

    function slv_to_hex(slv : std_logic_vector(11 downto 0)) return string is
        variable result  : string(1 to 3);
        variable nibble  : std_logic_vector(3 downto 0);
        variable val     : integer;
        constant HEX_CH  : string(1 to 16) := "0123456789ABCDEF";
    begin
        for i in 0 to 2 loop
            nibble := slv(11 - i*4 downto 8 - i*4);
            val := 0;
            for b in 0 to 3 loop
                if nibble(b) = '1' then
                    val := val + 2**b;
                end if;
            end loop;
            result(i + 1) := HEX_CH(val + 1);
        end loop;
        return result;
    end function;

    function decode_instr(instr : std_logic_vector(11 downto 0)) return string is
        variable op   : std_logic_vector(1 downto 0);
        variable reg  : std_logic_vector(2 downto 0);
        variable src  : std_logic_vector(2 downto 0);
        variable imm  : std_logic_vector(3 downto 0);
    begin
        op  := instr(11 downto 10);
        reg := instr(9  downto 7);
        src := instr(6  downto 4);
        imm := instr(6  downto 3);
        case op is
            when "00"   => return "ADD  R" & integer'image(to_integer(unsigned(reg)))
                                  & ",R"   & integer'image(to_integer(unsigned(src)));
            when "01"   => return "NEG  R" & integer'image(to_integer(unsigned(reg)))
                                  & ",R"   & integer'image(to_integer(unsigned(src)));
            when "10"   => return "MOVI R" & integer'image(to_integer(unsigned(reg)))
                                  & ","    & integer'image(to_integer(unsigned(imm)));
            when "11"   => return "JZR  R" & integer'image(to_integer(unsigned(reg)))
                                  & ","    & integer'image(to_integer(unsigned(imm)));
            when others => return "UNKNOWN";
        end case;
    end function;

begin


    UUT : Program_ROM
        port map (
            program_counter => tb_program_counter,
            instruction_out => tb_instruction_out
        );

    stim_proc : process
        variable pass_count : integer := 0;
        variable fail_count : integer := 0;
    begin

        report "======================================================" severity note;
        report "  Program_ROM Testbench Start                         " severity note;
        report "======================================================" severity note;

        report "--- Test 1: Sequential (0 to 7) ---" severity note;
        for i in 0 to 7 loop
            tb_program_counter <= std_logic_vector(to_unsigned(i, tb_program_counter'length));
            wait for PROP_DELAY;

            if tb_instruction_out = EXPECTED_ROM(i) then
                report "PASS | Addr " & integer'image(i)
                       & " | " & slv_to_hex(tb_instruction_out)
                       & " | " & decode_instr(tb_instruction_out)
                       severity note;
                pass_count := pass_count + 1;
            else
                report "FAIL | Addr " & integer'image(i)
                       & " | Exp:" & slv_to_hex(EXPECTED_ROM(i))
                       & " Got:"   & slv_to_hex(tb_instruction_out)
                       severity error;
                fail_count := fail_count + 1;
            end if;
        end loop;

        report "--- Test 2: Reverse (7 down to 0) ---" severity note;
        for i in 7 downto 0 loop
            tb_program_counter <= std_logic_vector(to_unsigned(i, tb_program_counter'length));
            wait for PROP_DELAY;

            if tb_instruction_out = EXPECTED_ROM(i) then
                report "PASS | Addr " & integer'image(i)
                       & " | " & slv_to_hex(tb_instruction_out)
                       severity note;
                pass_count := pass_count + 1;
            else
                report "FAIL | Addr " & integer'image(i)
                       & " | Exp:" & slv_to_hex(EXPECTED_ROM(i))
                       & " Got:"   & slv_to_hex(tb_instruction_out)
                       severity error;
                fail_count := fail_count + 1;
            end if;
        end loop;

        report "--- Test 3: Stability (3 passes) ---" severity note;
        for rep in 1 to 3 loop
            for i in 0 to 7 loop
                tb_program_counter <= std_logic_vector(to_unsigned(i, tb_program_counter'length));
                wait for PROP_DELAY;

                if tb_instruction_out /= EXPECTED_ROM(i) then
                    report "FAIL stability pass " & integer'image(rep)
                           & " Addr " & integer'image(i)
                           & " Exp:"  & slv_to_hex(EXPECTED_ROM(i))
                           & " Got:"  & slv_to_hex(tb_instruction_out)
                           severity error;
                    fail_count := fail_count + 1;
                else
                    pass_count := pass_count + 1;
                end if;
            end loop;
        end loop;
        report "Stability test complete." severity note;

        report "--- Test 4: Field-level checks ---" severity note;

        -- Addr 0: MOVI R7, 5 => op=10 reg=111 imm=0101
        tb_program_counter <= std_logic_vector(to_unsigned(0, tb_program_counter'length));
        wait for PROP_DELAY;
        assert tb_instruction_out(11 downto 10) = "10"
            report "FAIL | Addr0: opcode should be 10 (MOVI)" severity error;
        assert tb_instruction_out(9 downto 7) = "111"
            report "FAIL | Addr0: dst reg should be 111 (R7)" severity error;
        assert tb_instruction_out(6 downto 3) = "0101"
            report "FAIL | Addr0: immediate should be 0101 (5)" severity error;
        report "PASS | Addr 0 fields: MOVI R7,5 correct." severity note;
        pass_count := pass_count + 1;

        -- Addr 2: ADD R7, R6 => op=00 dst=111 src=110
        tb_program_counter <= std_logic_vector(to_unsigned(2, tb_program_counter'length));
        wait for PROP_DELAY;
        assert tb_instruction_out(11 downto 10) = "00"
            report "FAIL | Addr2: opcode should be 00 (ADD)" severity error;
        assert tb_instruction_out(9 downto 7) = "111"
            report "FAIL | Addr2: dst should be 111 (R7)" severity error;
        assert tb_instruction_out(6 downto 4) = "110"
            report "FAIL | Addr2: src should be 110 (R6)" severity error;
        report "PASS | Addr 2 fields: ADD R7,R6 correct." severity note;
        pass_count := pass_count + 1;

        -- Addr 7: JZR R7, 0 => op=11 reg=111 addr=0000
        tb_program_counter <= std_logic_vector(to_unsigned(7, tb_program_counter'length));
        wait for PROP_DELAY;
        assert tb_instruction_out(11 downto 10) = "11"
            report "FAIL | Addr7: opcode should be 11 (JZR)" severity error;
        assert tb_instruction_out(9 downto 7) = "111"
            report "FAIL | Addr7: reg should be 111 (R7)" severity error;
        assert tb_instruction_out(6 downto 3) = "0000"
            report "FAIL | Addr7: jump addr should be 0000" severity error;
        report "PASS | Addr 7 fields: JZR R7,0 correct." severity note;
        pass_count := pass_count + 1;

        report "-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-" severity note;
        report "  TESTBENCH COMPLETE" severity note;
        report "  PASSED : " & integer'image(pass_count) severity note;
        report "  FAILED : " & integer'image(fail_count) severity note;
        if fail_count = 0 then
            report "  RESULT : ALL TESTS PASSED" severity note;
        else
            report "  RESULT : FAILURES DETECTED" severity failure;
        end if;
        report "-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-" severity note;

        wait;
    end process;

end Behavioral;