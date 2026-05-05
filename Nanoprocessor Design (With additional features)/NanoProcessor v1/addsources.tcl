# =============================================================================
# add_sources.tcl
# Adds all NanoProcessor source files to the current Vivado project.
#
# HOW TO RUN ?? copy exactly as shown into the Vivado Tcl Console:
#
#   source {D:/NANO/Nanoprocessor Design (With additional features)/NanoProcessor v1/add_sources.tcl}
#
# The outer curly braces { } are REQUIRED because the path contains
# spaces and parentheses.  Without them you get:
#   ERROR: File or Directory 'D:/NANO/Nanoprocessor' does not exist
# =============================================================================

# Build the root path piece-by-piece so no special characters cause issues
set root [file join {D:} NANO \
    {Nanoprocessor Design (With additional features)} \
    {NanoProcessor v1}]

puts "Root path resolved to: $root"

# Verify the root exists before continuing
if {![file isdirectory $root]} {
    error "Cannot find project root: $root\nCheck that the drive and folder names are correct."
}

# =============================================================================
# Helper proc ?? adds one file, prints OK or MISSING
# =============================================================================
proc add_src {path} {
    if {[file exists $path]} {
        add_files -norecurse $path
        puts "  OK  : [file tail $path]"
    } else {
        puts "  MISS: $path"
    }
}

# =============================================================================
# DESIGN SOURCES ?? compile order from NanoProcessor.vhd header
# =============================================================================
puts "------------------------------------------------------------"
puts " Adding design sources..."
puts "------------------------------------------------------------"

# 1-2  Packages
add_src [file join $root Packages BusDefinitions.vhd]
add_src [file join $root Packages constants.vhd]

# 3-5  3-bit Adder primitives
add_src [file join $root {Source files} {3-bit Adder} HA.vhd]
add_src [file join $root {Source files} {3-bit Adder} FA.vhd]
add_src [file join $root {Source files} {3-bit Adder} RCA_3.vhd]

# 6-7  Decoders
add_src [file join $root {Source files} Decoders Decoder_2_to_4.vhd]
add_src [file join $root {Source files} Decoders Decoder_3_to_8.vhd]

# 8    D Flip-Flop
add_src [file join $root {Source files} {D Flip Flop} D_FF.vhd]

# 9-10 Register Bank
add_src [file join $root {Source files} {Register Bank} Reg.vhd]
add_src [file join $root {Source files} {Register Bank} Register_Bank.vhd]

# 11-13 MUXes
add_src [file join $root {Source files} MUX MUX_2W_3B.vhd]
add_src [file join $root {Source files} MUX MUX_2W_4B.vhd]
add_src [file join $root {Source files} MUX MUX_8W_4B.vhd]

# 14   Program Counter
add_src [file join $root {Source files} {Program Counter} Program_Counter.vhd]

# 15   Program Counter Adder
add_src [file join $root {Source files} {Program Counter Adder} Program_Counter_Adder.vhd]

# 16   Address Selector
add_src [file join $root {Source files} Adress_Selector Address_selector.vhd]

# 17   Load Selector
add_src [file join $root {Source files} Load_Selector Load_Selector.vhd]

# 18   Extended ALU
add_src [file join $root {Source files} {4-bit Add_Subtract unit} Extended_ALU.vhd]

# 19   Instruction Decoder
add_src [file join $root {Source files} {Instruction Decoder} Instruction_Decoder.vhd]

# 20   LUT 16-to-7
add_src [file join $root {Source files} {Look up tables} LUT_16_7.vhd]

# 21   Slow Clock
add_src [file join $root {Source files} Slow_Clock Slow_Clk.vhd]

# 22   Program ROM
add_src [file join $root {Source files} {Program Rom} Program_ROM.vhd]

# 23   TOP FILE ?? must be last
add_src [file join $root {Source files} {Top file} NanoProcessor.vhd]

# =============================================================================
# CONSTRAINTS
# =============================================================================
puts "------------------------------------------------------------"
puts " Adding constraints..."
puts "------------------------------------------------------------"
set xdc [file join $root NanoProcessor_Basys3.xdc]
if {[file exists $xdc]} {
    add_files -fileset constrs_1 -norecurse $xdc
    puts "  OK  : NanoProcessor_Basys3.xdc"
} else {
    puts "  MISS: NanoProcessor_Basys3.xdc"
}

# =============================================================================
# SET TOP MODULE
# =============================================================================
set_property top NanoProcessor [current_fileset]
puts "------------------------------------------------------------"
puts " Top module set to: NanoProcessor"

# =============================================================================
# SET VHDL-2008 ON ALL DESIGN FILES
# (Required for the 'variable' construct inside Extended_ALU process)
# =============================================================================
set_property file_type {VHDL 2008} [get_files -filter {FILE_TYPE == VHDL} -of_objects [get_filesets sources_1]]
puts " VHDL-2008 applied to all design sources."

# =============================================================================
# SUMMARY
# =============================================================================
puts "============================================================"
puts " Files now in project (sources_1):"
foreach f [get_files -of_objects [get_filesets sources_1]] {
    puts "   [file tail $f]"
}
puts "============================================================"
puts ""
puts " DO NOT add these files (they will cause errors or warnings):"
puts "   Register Bank/BusDefinitions.vhd  <- duplicate package (COMPILE ERROR)"
puts "   New folder/MUL_4B.vhd             <- stray copy"
puts "   New folder/adders.vhd             <- stray copy"
puts "   4-bit Add_Subtract unit/MUL_4B.vhd    <- signed mult, not in hierarchy"
puts "   4-bit Add_Subtract unit/Mul_4bit.vhd   <- standalone, not in hierarchy"
puts "   4-bit Add_Subtract unit/Add_Sub_4_bit.vhd <- not in hierarchy"
puts "   4-bit Add_Subtract unit/RCA_4.vhd  <- only used by Add_Sub_4_bit"
puts "============================================================"
puts " Done! You can now run Synthesis."

