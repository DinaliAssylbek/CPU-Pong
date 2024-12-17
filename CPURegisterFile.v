module RegFile (
	 input Reset,
    input clk,                    // Clock signal
    input En,                     // Write enable signal
    input [3:0] read_addr,        // Read address for first operand
    input [3:0] readwrite_addr,   // Write address (same as one read address)
    input [15:0] write_data,      // Data to be written to register
    output [15:0] read_data1,     // First operand output
    output [15:0] read_data2      // Second operand output
);

	// Register file array: 16 registers, each 16 bits wide
	reg [15:0] registers [15:0];
	integer i; // Initialize variable for looping through all registers
	 
	// Load registers with file (all zeros) 
	initial begin
		$readmemb("C:/Users/Dinal/Documents/TempReg.dat",registers);
	end

always @(posedge clk or negedge Reset) begin
        if (!Reset) begin
            for (i = 0; i < 16; i = i + 1) begin
		    registers[i] <= 16'h0000; // Loop through and clear all registers on reset
            end
        end 
	else if (En) begin // Check to see if we are writing to a register
            registers[readwrite_addr] <= write_data; // Write to the register
        end
		  end
	//    // Reading data: Continuous assignment (we should always be reading)
 assign read_data2 = registers[read_addr]; // Read from first register
 assign read_data1 = registers[readwrite_addr]; // Read from second register
//    // Writing data: Synchronous (on clock edge)

endmodule