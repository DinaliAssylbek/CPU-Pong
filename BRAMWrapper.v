module bram_memory_wrapper
#(parameter DATA_WIDTH = 16, parameter ADDR_WIDTH = 16) 
(
    input [(DATA_WIDTH-1):0] cont_1, cont_2,  // Controller inputs
    input [(DATA_WIDTH-1):0] data_a,          // Data inputs
    input [(ADDR_WIDTH-1):0] addr_a, addr_b,  // Address inputs
    input we_a, clk,                          // Write enables and clock
    output [(DATA_WIDTH-1):0] q_a, q_b        // Data outputs (changed to wires)
);

// Internal signals for write enable and data
reg we_a_internal;
reg [(DATA_WIDTH-1):0] data_a_internal;
reg we_b_internal;
reg [(DATA_WIDTH-1):0] data_b_internal;

// Wires for BRAM outputs
wire [(DATA_WIDTH-1):0] q_a_wire, q_b_wire;

// Instantiate BRAM
bram_mmio bram_mmio_inst (
    .clk(clk),
    .data_a(data_a_internal), .data_b(data_b_internal),
    .addr_a(addr_a), .addr_b(addr_b),
    .we_a(we_a_internal), .we_b(we_b_internal),
    .q_a(q_a_wire), .q_b(q_b_wire)
);

// Assign BRAM outputs to the module outputs
assign q_a = q_a_wire;
assign q_b = q_b_wire;

always @ (*) begin
    // Default behavior
    we_a_internal <= we_a;          // Pass through external we_a
    data_a_internal <= data_a;      // Pass through external data_a
    we_b_internal <= 0;        // allow only reads for port b
    data_b_internal <= 16'b0;  // output zeros

    // Specifically Handle IO through port A
    // Intercept specific addresses for memory-mapped IO
    if (addr_a == 16'hC001) begin
        we_a_internal <= 1'b1;      // Enable write
        data_a_internal <= cont_1; // Write controller input 1
    end else if (addr_a == 16'hC002) begin
        we_a_internal <= 1'b1;      // Enable write
        data_a_internal <= cont_2; // Write controller input 2
    end
end

endmodule