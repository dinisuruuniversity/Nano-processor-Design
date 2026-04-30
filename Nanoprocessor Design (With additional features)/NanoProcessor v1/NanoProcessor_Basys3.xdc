## NanoProcessor – Basys 3 Constraints (XDC)
## Target: Digilent Basys 3 (Xilinx Artix-7 XC7A35T-1CPG236C)

## ===========================================================================
## Clock
## ===========================================================================
set_property PACKAGE_PIN W5  [get_ports Clk]
set_property IOSTANDARD LVCMOS33 [get_ports Clk]
create_clock -period 10.000 -name sys_clk [get_ports Clk]

## ===========================================================================
## Reset  (btnC – centre push button, active-high)
## ===========================================================================
set_property PACKAGE_PIN U18 [get_ports Reset]
set_property IOSTANDARD LVCMOS33 [get_ports Reset]

## ===========================================================================
## LEDs  – show R1 value (result register) on LD3..LD0
## ===========================================================================
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}]

## ===========================================================================
## 7-Segment Display – Cathodes (active-low segments)
## seg[6]=CA  seg[5]=CB  seg[4]=CC  seg[3]=CD
## seg[2]=CE  seg[1]=CF  seg[0]=CG
## ===========================================================================
set_property PACKAGE_PIN W7  [get_ports {seg[6]}]
set_property PACKAGE_PIN W6  [get_ports {seg[5]}]
set_property PACKAGE_PIN U8  [get_ports {seg[4]}]
set_property PACKAGE_PIN V8  [get_ports {seg[3]}]
set_property PACKAGE_PIN U5  [get_ports {seg[2]}]
set_property PACKAGE_PIN V5  [get_ports {seg[1]}]
set_property PACKAGE_PIN U7  [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

## ===========================================================================
## 7-Segment Display – Anodes (active-low; an="1110" → rightmost digit)
## ===========================================================================
set_property PACKAGE_PIN U2  [get_ports {an[0]}]
set_property PACKAGE_PIN U4  [get_ports {an[1]}]
set_property PACKAGE_PIN V4  [get_ports {an[2]}]
set_property PACKAGE_PIN W4  [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
