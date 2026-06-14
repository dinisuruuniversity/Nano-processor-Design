# Nano-processor-Design
# 4-Bit NanoProcessor: Basic, Enhanced, & Optimized Architectures

A fully functional 4-bit microprocessor designed, simulated, and deployed on a **Basys 3 FPGA** using **VHDL**. This project spans three architectural iterations, demonstrating a complete hardware engineering lifecycle from baseline functionality to a highly optimized, resource-efficient system.

## 🚀 Project Overview
This project showcases the implementation of a custom ISA (Instruction Set Architecture) on hardware. The processor features an Instruction Decoder, Register Bank, Arithmetic Logic Unit (ALU), Program Counter, and ROM.

### Architectural Iterations:
1. **Basic:** Baseline functional architecture implementing core logic and standard arithmetic/logic instructions.
2. **Enhanced:** Added advanced instructions, improved pipelining/data path efficiency, or expanded control logic.
3. **Optimized:** Focused on resource utilization (reducing LUTs and Flip-Flops) and improving maximum clock frequency ($f_{max}$).

## 🛠️ Tech Stack & Tools
* **Language:** VHDL
* **Software:** Xilinx Vivado (Simulation & Synthesis)
* **Hardware:** Basys 3 FPGA (Artix-7)


## 🔍 Verification & Deployment
* **Simulation:** Verified using custom testbenches in Vivado Simulator (behavioral simulation).
* **Hardware Testing:** Successfully synthesized, implemented, and generated bitstream to test execution on the Basys 3 board using onboard switches and LEDs.

