----------------------------------------------------------------------------------
-- Module Name: Register_Bank - Behavioral
-- Description: 8 x 4-bit Register Bank (R0 to R7).
--
--   * R0 is hardwired to "0000" ?? its D input is permanently tied to zero.
--   * R1-R7 are general-purpose registers written via decoded enable signals.
--   * A 3-to-8 decoder (always enabled) converts Reg_En address to one-hot
--     register select lines (Reg_Sel).
--   * All register outputs are exposed simultaneously through Register_Outputs,
--     allowing the rest of the CPU to read any register without a mux here.
--   * Reset is asynchronous and shared with the Program Counter reset button.
--
-- Ports:
--   Data             : 4-bit write data input
--   Reset            : Asynchronous active-high reset (clears all registers)
--   Reg_En           : 3-bit write address (selects destination register)
--   Clock            : System clock
--   Register_Outputs : All 8 register values (index 0=R0 .. index 7=R7)
--
-- Compile order:
--   1. BusDefinitions.vhd
--   2. Decoder_2_to_4.vhd
--   3. Decoder_3_to_8.vhd
--   4. Reg.vhd
--   5. Register_Bank.vhd  (this file)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

entity Register_Bank is
    Port (
        Data             : in  DataBus;          -- 4-bit data to write
        Reset            : in  STD_LOGIC;        -- Asynchronous reset
        Reg_En           : in  RegisterSelect;   -- 3-bit write address (R0-R7)
        Clock            : in  STD_LOGIC;        -- System clock
        Register_Outputs : out RegisterFile      -- All 8 register contents
    );
end Register_Bank;

architecture Behavioral of Register_Bank is

    -- -------------------------------------------------------------------------
    -- Component: 3-to-8 Decoder (Lab 4)
    -- -------------------------------------------------------------------------
    component Decoder_3_to_8
        Port (
            I  : in  STD_LOGIC_VECTOR (2 downto 0);
            EN : in  STD_LOGIC;
            Y  : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- -------------------------------------------------------------------------
    -- Component: 4-bit Register with asynchronous reset and clock enable
    -- -------------------------------------------------------------------------
    component Reg
        Port (
            D   : in  STD_LOGIC_VECTOR (3 downto 0);
            Res : in  STD_LOGIC;
            En  : in  STD_LOGIC;
            Clk : in  STD_LOGIC;
            Q   : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    -- One-hot register write-enable lines from the decoder
    signal Reg_Sel : STD_LOGIC_VECTOR (7 downto 0);

begin

    -- -------------------------------------------------------------------------
    -- 3-to-8 Decoder: always enabled; Reg_En selects which Reg_Sel line goes
    -- high. The CPU must gate Reg_En externally when no write is intended
    -- (e.g. point to R0 or hold a separate write-enable flag in the controller).
    -- -------------------------------------------------------------------------
    Decoder_3_to_8_0 : Decoder_3_to_8
        port map (
            I  => Reg_En,
            EN => '1',
            Y  => Reg_Sel
        );

    -- -------------------------------------------------------------------------
    -- R0 - Zero Register
    -- D is permanently "0000". En is '1' so it always holds zero after reset.
    -- -------------------------------------------------------------------------
    Zero_Register : Reg
        port map (
            D   => "0000",
            Res => Reset,
            En  => '1',
            Clk => Clock,
            Q   => Register_Outputs(0)
        );

    -- -------------------------------------------------------------------------
    -- R1 to R7 - General Purpose Registers
    -- -------------------------------------------------------------------------
    Register_1 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(1),
            Clk => Clock,
            Q   => Register_Outputs(1)
        );

    Register_2 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(2),
            Clk => Clock,
            Q   => Register_Outputs(2)
        );

    Register_3 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(3),
            Clk => Clock,
            Q   => Register_Outputs(3)
        );

    Register_4 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(4),
            Clk => Clock,
            Q   => Register_Outputs(4)
        );

    Register_5 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(5),
            Clk => Clock,
            Q   => Register_Outputs(5)
        );

    Register_6 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(6),
            Clk => Clock,
            Q   => Register_Outputs(6)
        );

    Register_7 : Reg
        port map (
            D   => Data,
            Res => Reset,
            En  => Reg_Sel(7),
            Clk => Clock,
            Q   => Register_Outputs(7)
        );

end Behavioral;

