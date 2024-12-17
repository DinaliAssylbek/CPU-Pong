// Instruction register holds current instruction that displays when Enable is high
// Works with Controller FSM, takes in 16 bit instruction and outputs
// the opcode, opcode extension/ Immediate high, Rdest, and Rsrc

module InstrReg(

input clk,
input En,
input [15:0] instruction,

output reg[3:0] opcode,
output reg[3:0] opcodeExt_ImmHi,
output reg[3:0] Rdest,
output reg[3:0] Rsrc_ImmLo

);

always @(posedge clk)

	// Only update outputs when enable is high
	if(En)begin
		opcode <= instruction[15:12]; //put top 4 bits in opcode output
		Rdest <= instruction[11:8];	//put next 4 bits in Rdest output
		opcodeExt_ImmHi <= instruction[7:4];	//put next 4 bits in opcodeExt_ImmHi output
		Rsrc_ImmLo <= instruction[3:0]; //put last 4 bits in Rsrc_ImmLo output
	end
	
endmodule