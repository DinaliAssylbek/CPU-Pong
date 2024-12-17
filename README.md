# CPU Pong Project

## Overview

## Finite State Machine
The FSM operates in the following states:


Fetch: Read instructions from memory at the current program counter (PC) address.

Decode: Interpret the instruction into segments (Opcode, Ext, Rdest, Rsrc).

AluEx: Execute ALU instructions.

MemEx: Perform memory access for load/store instructions.

Jex: Handle jump instructions, including JAL (jump-and-link) and RET.

Write-Back (RegWb, MemWb, JexWB): Write results back to registers or memory.

## Key Components
Instruction Register: Holds the fetched 16-bit instruction.

Register File: Contains the general-purpose registers.

ALU (Arithmetic Logic Unit): Executes arithmetic and logic operations.

Memory Module: Provides dual-port instruction and data storage.

Program Counter (PC): Tracks the current execution address.

PC Control Module: Updates the PC for jump instructions.

Muxes and Control Signals: Allow proper data flow and state transitions.

## Memory System
The CPU utalizes a random access memory (RAM) with the following properties: 


Address Width: Each memory address holds 16 bits of data.

Total Memory: Half a megabyte (512 KB) of addressable memory.

Dual-Port Access: Allows simultaneous interactions from two entities (e.g., the CPU and VGA controller).

Memory-Mapped I/O: The memory includes hard-coded addresses for controller interactions via BRAM Wrapper.

- Two memory addresses are mapped to retrieve data directly from the controller.

## Instructions Supported
#### ALU Instructions
ADD, ADDI, SUB, SUBI, AND, ANDI, OR, ORI, XOR, XORI, CMP, CMPI, LSH, LSHI, RSH, RHSI
#### Memory Instructions
LOAD, STOR, LUI, MOV, MOVI
#### Jump Instructions
Jcond, Bcond, JAL, RET
