// Controller module is the finite state machine for the CPU
// it takes in the opcode and opcode extension/ immidiate high
// and output enable signals depending on state.
// Our FSM has 9 States and each instruction can go through up to 6 states

module Controller(
input clk,
input Reset,
input [3:0] OpCode,
input [3:0] OpCodeExt_ImmHi,
input [3:0] RSource_ImmLo,    // may be able to omit

output reg AluEn,
output reg MemMuxEn,
output reg RegFileEn,
output reg MemWriteEn,
output reg PCEn,
output reg InstrEn,
output reg PCRead,
output reg PCWrite
);

// current state and next state registers
reg [3:0] state;
reg [3:0] NS;

//Stages
parameter FETCH = 4'b0000;
parameter DECODE = 4'b0001;
parameter MEMEX = 4'b0010; //Iex
parameter ALUEX = 4'b0011; //Iex
parameter REGWB = 4'b0111;
parameter MEMWB = 4'b0100;
parameter JEX = 4'b0101;
parameter JEXWB = 4'b1000;
parameter PCUPDATE = 4'b1111;


//Opcodes
parameter MEMTYPE = 4'b0100;
parameter BranchTYPE = 4'b1100;
// Next state logic
always @(posedge clk) begin
	if(~Reset)
	begin
	state <= FETCH;
	end
	else state <= NS;
end

initial begin
	state <= FETCH;
	NS <= FETCH;
end

always @(*) begin
	NS <= FETCH;

//Do cases
	case(state)
		FETCH:NS<= DECODE;
		// Decode instruction 
		DECODE:begin
			case(OpCode)
				// Check if mem type
				MEMTYPE:begin
					if(OpCodeExt_ImmHi == 4'b0000 || OpCodeExt_ImmHi == 4'b0100)begin
					NS <= MEMEX; //STOR and LOAD
					end
					if(OpCodeExt_ImmHi == 4'b1100 || OpCodeExt_ImmHi == 4'b1000 || OpCodeExt_ImmHi == 4'b1111)begin
					NS <= JEX; //Jump
					end
				end
				// Check if opcode is branch type
				BranchTYPE: NS <= JEX;
				// Defualt to ALU instuction
				default: NS <= ALUEX;
				endcase
		end
		
		MEMEX:NS <= MEMWB;
		ALUEX:NS <= REGWB;
		REGWB: NS <= JEX;
		MEMWB: NS <= JEX;
		JEX: NS <= JEXWB;
		JEXWB: NS <= PCUPDATE;
		PCUPDATE: NS <= FETCH;
		default:NS <= FETCH;
	endcase
		if(~Reset)
		begin
			NS <= FETCH;
		end
end
// State logic
always @(*) begin
	
	AluEn <= 0;
	MemMuxEn <= 0;
	RegFileEn <= 0;
	PCEn <= 0;
	MemWriteEn <= 0;
	InstrEn <= 0;
	PCRead <= 0;
	PCWrite <= 0;

	case(state)
		// initalize all enables as low, expcept for PCread and Instruction enable to fetch instruction
		FETCH:begin
			AluEn <= 0;
			MemMuxEn <= 0;
			RegFileEn <= 0;
			PCEn <= 0;
			MemWriteEn <= 0;
			InstrEn <= 1;
			PCRead <= 1;
			PCWrite <= 0;
		end
		// Do nothing here as all it does is calculate next state logic in the previous always @ block
		DECODE:begin
			//RegFileEn <=0;
			//InstrEn <= 0;
		end
		// If memory execute enable memory mux
		MEMEX: begin
		MemMuxEn <= 1;
		end
		// If ALU execute, enable ALU
		ALUEX:AluEn <= 1;
		// Write back logic for memory instructions (store and load)
		MEMWB:begin
			// If store
			if(OpCode == 4'b0100 && OpCodeExt_ImmHi == 4'b0100) begin
				MemWriteEn <=1;
				RegFileEn <= 0;
			end
			// If load
			else if(OpCode == 4'b0100 && OpCodeExt_ImmHi == 4'b0000)begin
				MemMuxEn <= 1;
				RegFileEn <= 1;
			end
			else
			RegFileEn <=1;
		end
		// Register write back logic for ALU instructions
		REGWB: begin
		if((OpCode == 4'b0000 && OpCodeExt_ImmHi == 4'b1011)||(OpCode == 4'b1011 || (OpCode == 4'b0100 && OpCodeExt_ImmHi == 4'b0100))) RegFileEn <=0;
		else RegFileEn <=1;
		AluEn <= 1;
		end
		// Jump execute, enable PC
		JEX: begin
			PCEn <= 1;
			//PCReadWrite <=1;
			//MemWriteEn <= 1;
		end
		// Write back logic for jump type, enable mem write so PC can be properly updated
		JEXWB: begin
			PCWrite <=1;
			MemWriteEn <= 1;
		end
		// PC is read when pc has been updated
		PCUPDATE: begin
			PCRead <= 1;
		end
		// Default case, dont write to registers
		default: RegFileEn <=0;
		endcase
end
endmodule