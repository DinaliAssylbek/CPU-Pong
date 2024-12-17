module bram_mmio
#(parameter DATA_WIDTH = 16, parameter ADDR_WIDTH = 16) 
(
    input [(DATA_WIDTH-1):0] data_a, data_b, // data inputs
    input [(ADDR_WIDTH-1):0] addr_a, addr_b, // address inputs
    input we_a, we_b, clk, // write enables and clock
    output reg [(DATA_WIDTH-1):0] q_a, q_b // data outputs
);
    reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH - 1:0]; // instantiates memory block, up to 65k memory locations for our 16 bit addr and data width
	initial begin
	   $readmemh("C:/Users/Dinal/Documents/Utah Fall 24/CS 3710/ISA_PythonCompiler/memory_output.txt", ram); // loads memory with our instructions
	end
	
    // Port A 
    always @ (posedge clk)
    begin
	if (we_a) begin // check if we are writing to port A
	   ram[addr_a] <= data_a; // write the data to memory at address a
	   q_a <= data_a; // set the output to the data that is being written
	end else begin
	   q_a <= ram[(addr_a)]; // otherwise, read the data at the location of address a
	end
    end

    // Port B 
    always @ (posedge clk)
    begin
	if (we_b) begin // check if we are writing to port B
	   ram[(addr_b)] <= data_b; // write the data to memory at address b
           q_b <= data_b; // set the output to the data that is being written
        end
        else begin
	   q_b <= ram[(addr_b)]; // otherwise, read the data at the location of address b
        end
    end
endmodule