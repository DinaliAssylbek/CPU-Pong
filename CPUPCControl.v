module PCControl(
input clk, PCen, Reset,
input [15:0] PSR,            //Inputs PSR from REG
input [15:0] RegData,
input [3:0] dispLo,          //Target Register address or Dislo
input [3:0] OpcodeExt_dispHi,
input [3:0] CondRlink,       //Link Register or condition.
input [3:0] Opcode,          //2-bits from Decoder indicating "jump" type
output reg [15:0]PC          // Program counter register value
);

reg [3:0] RlinkIndex;
reg [15:0] Rlink [7:0];

// instruction Types
parameter JUMP = 4'b0100;
parameter BCOND = 4'b1100;

// Condition Types
parameter EQ = 4'b0000; //Equal Z=1
parameter NE = 4'b0001; //Not Equal Z=0
parameter GE = 4'b1101; //Greater than or Equal N=1 or Z=1
parameter CS = 4'b0010; //Carry Set C=1
parameter CC = 4'b0011; //Carry Clear C=0
parameter HI = 4'b0100; //Higher than L=1
parameter LS = 4'b0101; //Lower than or Same as L=0
parameter LO = 4'b1010; //Lower than L=0 and Z=0
parameter HS = 4'b1011; //Higher than or Same as L=1 or Z=1
parameter GT = 4'b0110; //Greater Than N=1
parameter LE = 4'b0111; //Less than or Equal N=0
parameter FS = 4'b1000; //Flag Set F=1
parameter FC = 4'b1001; //Flag Clear F=0
parameter LT = 4'b1100; //Less Than N=0 and Z=0
parameter UC = 4'b1110; //Unconditional N/A

//OpCodeExt
parameter JAL = 4'b1000; //Jump and link
parameter JCOND = 4'b1100; //Jump conditional
parameter RET = 4'b1111; //Jump Unconditional to link

initial begin
	PC <= 16'h0;
	RlinkIndex <= 0;
end

always @(posedge clk) begin
if(~Reset) PC <= 16'h0;
if(PCen)begin
    case (Opcode)
        JUMP: begin
            case (OpcodeExt_dispHi)
                JAL: begin
                    // Store PC in the "stack" and increment
						  if (RlinkIndex < 8) begin
								Rlink[RlinkIndex] <= PC + 1'b1;
								RlinkIndex <= RlinkIndex + 1'b1;
							end
                    PC <= RegData;
                end
                JCOND: begin
                    case (CondRlink)
                        EQ: PC <= PSR[6] ? RegData : PC + 1'b1;  // Z=1
                        NE: PC <= ~PSR[6] ? RegData : PC + 1'b1; // Z=0
                        GE: PC <= (PSR[7] | PSR[6]) ? RegData : PC + 1'b1; // N=1 or Z=1
                        CS: PC <= PSR[0] ? RegData : PC + 1'b1; // C=1
                        CC: PC <= ~PSR[0] ? RegData : PC + 1'b1; // C=0
                        HI: PC <= PSR[2] ? RegData : PC + 1'b1; // L=1
                        LS: PC <= ~PSR[2] ? RegData : PC + 1'b1; // L=0
                        LO: PC <= (~PSR[2] & ~PSR[6]) ? RegData : PC + 1'b1; // L=0 and Z=0
                        HS: PC <= (PSR[2] | PSR[6]) ? RegData : PC + 1'b1; // L=1 and Z=1
                        GT: PC <= PSR[7] ? RegData : PC + 1'b1; // N=1
                        LE: PC <= ~PSR[7] ? RegData : PC + 1'b1; // N=0
                        FS: PC <= PSR[5] ? RegData : PC + 1'b1; // F=1
                        FC: PC <= ~PSR[5] ? RegData : PC + 1'b1; // F=0
                        LT: PC <= (~PSR[7] & ~PSR[6]) ? RegData : PC + 1'b1; // N=0 and Z=0
                        UC: PC <= RegData; // Unconditional
                        default: PC <= PC + 1'b1; // Should never happen
                    endcase
                end
                RET: begin
                // Load PC from stack and decrement
					 if(RlinkIndex >0) begin
							RlinkIndex <= RlinkIndex - 1;
                    PC <= Rlink[RlinkIndex - 1];
                end else begin
					 //If stack is empty, just increment PC
						 PC <= PC +1;
						 end
					 end
                default: PC <= PC + 1'b1; // Should never happen
            endcase
        end
        BCOND: begin
            case (CondRlink)
                EQ: PC <= PSR[6] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1;  // Z=1
                NE: PC <= ~PSR[6] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // Z=0
                GE: PC <= (PSR[7] | PSR[6]) ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // N=1 or Z=1
                CS: PC <= PSR[0] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // C=1
                CC: PC <= ~PSR[0] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // C=0
                HI: PC <= PSR[2] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // L=1
                LS: PC <= ~PSR[2] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // L=0
                LO: PC <= (~PSR[2] & ~PSR[6]) ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // L=0 and Z=0
                HS: PC <= (PSR[2] | PSR[6]) ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // L=1 and Z=1
                GT: PC <= PSR[7] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // N=1
                LE: PC <= ~PSR[7] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // N=0
                FS: PC <= PSR[5] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // F=1
                FC: PC <= ~PSR[5] ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // F=0
                LT: PC <= (~PSR[7] & ~PSR[6]) ? PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]} : PC + 1'b1; // N=0 and Z=0
                UC: PC <= PC + {{8{OpcodeExt_dispHi[3]}},OpcodeExt_dispHi[3:0], dispLo[3:0]}; // Unconditional
                default: PC <= PC + 1'b1; // Should never happen
            endcase
        end
        default: PC <= PC + 1'b1; // Regular increment
    endcase
	 end
end
endmodule