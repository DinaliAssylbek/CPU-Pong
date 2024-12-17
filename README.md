# CPU Pong Project

### Overview

This project implements a CPU that follows the CR-16 instruction set architecture. The CPU is designed as part of a larger project to create the classic Pong game for CS 3710 at the University of Utah. The CPU operates with the following key specifications:

Clock Frequency: 50 Hz

Maximum CPI (Cycles Per Instruction): 6

Memory: Dual-port, 512 KB RAM

### Finite State Machine
The FSM operates in the following states:


Fetch: Read instructions from memory at the current program counter (PC) address.

Decode: Interpret the instruction into segments (Opcode, Ext, Rdest, Rsrc).

AluEx: Execute ALU instructions.

MemEx: Perform memory access for load/store instructions.

Jex: Handle jump instructions, including JAL (jump-and-link) and RET.

Write-Back (RegWb, MemWb, JexWB): Write results back to registers or memory.

![1 (1)](https://github.com/user-attachments/assets/6d1462c4-9ce7-403f-b9ec-45b2cd2c577e)

### Key Components
Instruction Register: Holds the fetched 16-bit instruction.

Register File: Contains the general-purpose registers.

ALU (Arithmetic Logic Unit): Executes arithmetic and logic operations.

Memory Module: Provides dual-port instruction and data storage.

Program Counter (PC): Tracks the current execution address.

PC Control Module: Updates the PC for jump instructions.

Muxes and Control Signals: Allow proper data flow and state transitions.

### Memory System
The CPU utalizes a random access memory (RAM) with the following properties: 


Address Width: Each memory address holds 16 bits of data.

Total Memory: Half a megabyte (512 KB) of addressable memory.

Dual-Port Access: Allows simultaneous interactions from two entities (e.g., the CPU and VGA controller).

Memory-Mapped I/O: The memory includes hard-coded addresses for controller interactions via BRAM Wrapper.

- Two memory addresses are mapped to retrieve data directly from the controller.

### Instructions Supported
#### ALU Instructions
ADD, ADDI, SUB, SUBI, AND, ANDI, OR, ORI, XOR, XORI, CMP, CMPI, LSH, LSHI, RSH, RHSI
#### Memory Instructions
LOAD, STOR, LUI, MOV, MOVI
#### Jump Instructions
Jcond, Bcond, JAL, RET

## Data Path Diagram
![2](https://github.com/user-attachments/assets/5746f48c-e8ac-429c-a4a8-c2072cd9ef24)

