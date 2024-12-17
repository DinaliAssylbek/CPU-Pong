// ALUcntrl module will decide instruction type (I-Type/R-Type) and
// pass it to the ALU as well as the the Rsrc register / Immediate and will
// Sign extend/Zero Extend the immediate

module ALUcntrl
(
input [3:0] Opcode,
input [3:0] OpcodeExt_ImmHi,
input [15:0] Reg2Data,
input [3:0] Rsrc_ImmLo,

output reg [3:0] ALUctrl,
output reg [15:0] Rsrc_Imm
);

reg [15:0] signExt, zeroExt, shiftExt;
reg [7:0] Imm;

//ITYPE instructions
parameter ADDI = 4'b0101;
parameter SUBI = 4'b1001;
parameter CMPI = 4'b1011;
parameter ANDI = 4'b0001;
parameter ORI = 4'b0010;
parameter XORI = 4'b0011;
parameter MOVI = 4'b1101;
parameter LSH= 4'b1000;
parameter LUI = 4'b1111;


//RTYPE instructions
parameter ADD = 4'b0101;
parameter SUB = 4'b1001;
parameter CMP = 4'b1011;
parameter AND = 4'b0001;
parameter OR = 4'b0010;
parameter XOR = 4'b0011;
parameter MOV = 4'b1101;

initial begin
	Imm <= 8'b0;
end

always@(*) begin
	Rsrc_Imm <= 16'b0;
	Imm <= {OpcodeExt_ImmHi[3:0], Rsrc_ImmLo[3:0]}; // immediate
	zeroExt <= {8'b00000000, Imm[7:0]}; // zero extended immediate
	signExt <= {{8{Imm[7]}}, Imm[7:0]}; //sign extened immediate
	shiftExt <= {{12{Rsrc_ImmLo[3]}}, Imm[3:0]}; // the sign extended for shift instructions
	// If Opcode is I Type
	case(Opcode) 
		ADDI: begin ALUctrl <= 4'b0101; Rsrc_Imm <= signExt; end
		SUBI: begin ALUctrl <= 4'b1001; Rsrc_Imm <= signExt; end
		CMPI: begin ALUctrl <= 4'b1011; Rsrc_Imm <= signExt; end
		ANDI: begin ALUctrl <= 4'b0001; Rsrc_Imm <= zeroExt; end
		ORI: begin ALUctrl <= 4'b0010; Rsrc_Imm <= zeroExt; end
		XORI: begin ALUctrl <= 4'b0011; Rsrc_Imm <= zeroExt; end
		MOVI: begin ALUctrl <= 4'b1101; Rsrc_Imm <= zeroExt; end
		LSH:
			if(OpcodeExt_ImmHi[2]) // regular LSH
			begin
				ALUctrl <= 4'b0100;
			end
		else if (OpcodeExt_ImmHi[0])
			begin
				ALUctrl <= 4'b0111; // Right Shift
				Rsrc_Imm <= shiftExt;
			end
		else 
			begin
				ALUctrl <= 4'b0000; // Left Shift 
				Rsrc_Imm <= shiftExt;
			end
		LUI:
		begin
			ALUctrl <= 4'b1111; 
			Rsrc_Imm <= {{0{0}}, Imm[7:0]};
		end
		default: case(OpcodeExt_ImmHi) // R-Type instruction
			ADD: begin ALUctrl <= 4'b0101; Rsrc_Imm <= Reg2Data; end
			SUB: begin ALUctrl <= 4'b1001; Rsrc_Imm <= Reg2Data; end
			CMP: begin ALUctrl <= 4'b1011; Rsrc_Imm <= Reg2Data; end
			AND: begin ALUctrl <= 4'b0001; Rsrc_Imm <= Reg2Data; end
			OR: begin ALUctrl <= 4'b0010; Rsrc_Imm <= Reg2Data; end
			XOR: begin ALUctrl <= 4'b0011; Rsrc_Imm <= Reg2Data; end
			MOV: begin ALUctrl <= 4'b1101; Rsrc_Imm <= Reg2Data; end
			default: begin ALUctrl <= 4'b0000; Rsrc_Imm <= Reg2Data; end// This should never happen
			endcase
		endcase
	end
endmodule
// Performs ALU operations and keeps track of Program Status Register			
module ALU (
	input ALUen,
	input [15:0] Rdest,
	input [15:0] Rsrc,
	input [3:0] alucont,
	
	output reg [15:0] result,
	output reg [15:0] PSR
);

// ALU operations
parameter ADD = 4'b0101;
parameter SUB = 4'b1001;
parameter AND = 4'b0001;
parameter OR = 4'b0010;
parameter XOR = 4'b0011;
parameter LSH = 4'b0100;
parameter LSHI = 4'b0000;
parameter RSHI = 4'b0111;
parameter CMP = 4'b1011;
parameter MOV = 4'b1101;

// SPECIAL CASES
parameter LUI = 4'b1111;
reg [16:0] temp;  // Temporary register for overflow/carry calculations

initial begin
	PSR = 16'b0000000000000000; //rrrrIPE0NZF00LTC
end


always @(*) begin
	result = 16'b0;
	temp = 16'b0;
	// Reset all flags at the start of each operation
	if (ALUen) begin
	case (alucont)
		AND: result = Rdest & Rsrc; // AND Operation
		OR: result = Rdest | Rsrc;  // OR Operation
		XOR: result = Rdest ^ Rsrc; // XOR Operation
		MOV: result = Rsrc; 		// Move Operation
		
		ADD: begin
			temp = Rdest + Rsrc; // Temporary 16 bit computation
			result = temp[15:0]; // Result assignment of 16 bits
			PSR[0] = temp[16]; // Unsigned Carry Bit
			// Need more detection for overflow
			PSR[5] = (Rdest[15] == Rsrc[15]) && (result[15] != Rdest[15]); // Signed overflow detection
		end
		
		SUB: begin
			temp = Rdest + (~Rsrc + 1); // Temporary 16 bit computation
			result = temp[15:0]; // Result assignment of 15 bits
			PSR[0] = temp[16]; // Unsigned Carry Bit
			PSR[5] = (Rdest[15] != Rsrc[15]) && (result[15] != Rdest[15]); // Signed overflow detection
		end
		
		LSH: begin
			if (Rsrc == 16'b1111111111111111) begin      // Check if b is -1 (16-bit two's complement representation of -1)
				 result = Rdest >> 1;          				// Logical Shift Right by 1     
			end else if (Rsrc == 16'h0001) begin			// Check if b is 1 (16-bit two's complement representation of 1)
				 result = Rdest << 1;          				// Logical Shift Left by 1
			end else begin
				 result = Rdest;               				// Should never happen
			end
      end
		
		LSHI:begin
			result = Rdest << Rsrc; // Left Shift by Immidiate
		end
		
		RSHI:begin
			result = Rdest >> Rsrc; // Right Szhift by Immidiate
		end
		
		CMP: begin
			temp = Rdest - Rsrc;	// Store compare in temp variable
		   result = 16'b0;
			PSR[6] = (temp[15:0] == 16'b0);   // Zero flag if operands are equal
			PSR[7] = temp[16];                // Negative flag if the result is negative
			PSR[2] = (temp[15] == 1'b1);      // 'Less than' flag for signed comparison
		end

		LUI:
			result = (Rsrc << 8) | Rdest[7:0]; //Perform LUI by shifting left by 8 and masking lower 8 bits
		
		default: result = 16'b0; // Should Never Happen
		
	endcase
	end
end
endmodule
// 16 bit 2-1 MUX
module mux(
input [15:0] data1, data2,
input select,
output [15:0] dataout
);

assign dataout = select ? data1 : data2;

endmodule