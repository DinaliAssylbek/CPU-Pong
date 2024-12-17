module TopLevelBoard(
input clk,
input up1, up2, down1, down2, left1, left2, right1, right2, A_B1, A_B2, start_C1, start_C2,
input Reset,
input clr,
input vgaReset,

output wire [7:0] VGA_R, VGA_G, VGA_B,
output hSync, vSync,
output enable, bright, sync,
output selectOut1,
output selectOut2
);


//Wires coming out of each Moddule
//InstrReg
wire[3:0] OpCodeExt_ImmHi;
wire[3:0] OpCode;
wire[3:0] Rdest;
wire[3:0] Rsrc_ImmLo;

//COntroller
wire AluEn;
wire MemMuxEn;
wire RegFileEn;
wire MemWriteEn;
wire PCEn;
wire InstrEn;
wire PCRead;
wire PCWrite;

//PCControl
wire [15:0] PC;

//RegFile
wire[15:0] read_data1; // First operand output
wire[15:0] read_data2;

//Bram_mmio
wire [15:0] q_a, q_b;
wire [15:0] MemData;
wire [15:0] Boffsetaddr;
wire [15:0] data_b;
wire [15:0] addr_b;
wire we_b;

//ALUCtrl
wire [3:0] ALUctrl;
wire [15:0] Rsrc_Imm;
wire [15:0] Rsrc_ImmData;

//ALU
wire [15:0] ALUResult;
wire [15:0] PSR;
wire [3:0]alucont;

//Controller Connect
wire [15:0] Controlleroutput1;
wire [15:0] Controlleroutput2;

//muxes
wire [15:0] Mem_a1;
wire [15:0] MemAddr;
wire [15:0] AluMuxOut;
wire [15:0] MemDataFromMux;

InstrReg InstrReg(
.clk(clk),
.En(InstrEn),
.instruction(MemData),
.opcode(OpCode),
.opcodeExt_ImmHi(OpCodeExt_ImmHi),
.Rdest(Rdest),
.Rsrc_ImmLo(Rsrc_ImmLo)
);

Controller Controller(
	.clk(clk),
	.Reset(Reset),
	.OpCode(OpCode),
	.OpCodeExt_ImmHi(OpCodeExt_ImmHi),
	.RSource_ImmLo(Rsrc_ImmLo),
	.AluEn(AluEn),
	.MemMuxEn(MemMuxEn),
	.RegFileEn(RegFileEn),
	.PCEn(PCEn),
	.PCRead(PCRead),
	.PCWrite(PCWrite),
	.MemWriteEn(MemWriteEn),
	.InstrEn(InstrEn)
);

PCControl PCControl(
	.Reset(Reset),
	.clk(clk),
	.PSR(PSR),
	.PCen(PCEn),
	.RegData(read_data2),
	.dispLo(Rsrc_ImmLo),  //Target Register address or Dislo
	.OpcodeExt_dispHi(OpCodeExt_ImmHi),
	.CondRlink(Rdest),
	.Opcode(OpCode), //2-bits from Decoder indcationg "jump" type
	.PC(PC) // Program counter register value
);

bram_memory_wrapper bram_mmio //a is for FPGA, b is for VGA display
(
	 .cont_1(Controlleroutput1),
	 .cont_2(Controlleroutput2),
	 .clk(clk),
    .data_a(MemDataFromMux), 
    .addr_a(MemAddr), 
	 .addr_b(addr_b),
    .we_a(MemWriteEn), 
    .q_a(MemData),
	 .q_b(q_b)
);

VGA_top vt(

	.clk(clk),
	.clr(clr),
	.reset(vgaReset),
	.q_b(q_b),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.hSync(hSync),
	.vSync(vSync),
	.enable(enable),
	.bright(bright),
	.sync(sync),
	.addr_b(addr_b),
);

RegFile RegFile (
	 .Reset(Reset),
    .clk(clk),                // Clock signal
    .En(RegFileEn),                 // Write enable signal
    .read_addr(Rsrc_ImmLo), // Read address for first operand
    .readwrite_addr(Rdest),   // Write address (same as one read address)
    .write_data(AluMuxOut),  // Data to be written to register
    .read_data1(read_data1), // First operand output
    .read_data2(read_data2)  // Second operand output
);

ALUcntrl ALUcntrl
(
	.Opcode(OpCode),
	.OpcodeExt_ImmHi(OpCodeExt_ImmHi),
	.Reg2Data(read_data2),
	.Rsrc_ImmLo(Rsrc_ImmLo),
	.ALUctrl(alucont),
	.Rsrc_Imm(Rsrc_ImmData)
);


ALU ALU (
	.ALUen(AluEn),
	.Rdest(read_data1),
	.Rsrc(Rsrc_ImmData),
	.alucont(alucont),
	.result(ALUResult),
	.PSR(PSR)
);

Controller_connect Controller_connect(
	.up1(up1),
	.up2(up2),
	.down1(down1),
	.down2(down2), 
	.left1(left1),
	.left2(left2),
	.right1(right1),
	.right2(right2),
	.A_B1(A_B1),
	.A_B2(A_B2),
	.start_C1(start_C1),
	.start_C2(start_C2),
	.selectin1(selectOut1),
	.selectin2(selectOut2),
	.Controlleroutput1(Controlleroutput1), 
	.Controlleroutput2(Controlleroutput2)
);

//ALUMUX

mux muxALu(
.select(MemMuxEn),
.data1(MemData),
.data2(ALUResult),
.dataout(AluMuxOut)
);

//Memory address
mux muxMEM1(
.select(PCWrite),
.data1(16'h8000),
.data2(read_data2), //Switched to read_data 2, change back to read_data1 if not working
.dataout(Mem_a1)
);

//Memory address
mux muxMEM2(
.select(PCRead),
.data1(PC),
.data2(Mem_a1),
.dataout(MemAddr)
);

//Memory Data
mux muxMEMdata(
.select(PCWrite),
.data1(PC),
.data2(read_data1),
.dataout(MemDataFromMux)
);

endmodule
