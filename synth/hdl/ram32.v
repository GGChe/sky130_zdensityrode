`timescale 1ns / 1ps

module ram_wide #(
    parameter integer NUM_CHANNELS = 8,  // Number of channels
    parameter integer DATA_WIDTH   = 16, // Bits per channel
    parameter integer ADDR_WIDTH   = 5   // Enough for 32 entries
)(
    input  wire clk,
    input  wire rst,

    // Write inputs
    input  wire [(NUM_CHANNELS*DATA_WIDTH)-1:0] data_in,
    input  wire write_en,

    // Read inputs
    input  wire read_en,

    // Address for both read and write
    input  wire [ADDR_WIDTH-1:0] addr,

    // Outputs
    output wire ram_full, // Example "full" flag
    output reg [(NUM_CHANNELS*DATA_WIDTH)-1:0] data_out
);

    // Memory array: each address holds NUM_CHANNELS * DATA_WIDTH bits
    reg [(NUM_CHANNELS*DATA_WIDTH)-1:0] ram_mem [0:(1<<ADDR_WIDTH)-1];

    // Simple 'full' logic example: '1' when addr is all 1s
    assign ram_full = (addr == {ADDR_WIDTH{1'b1}});

    // Write-first single-port RAM behavior
    always @(posedge clk) begin
        if (rst) begin
            data_out <= { (NUM_CHANNELS*DATA_WIDTH){1'b0} };
        end
        else begin
            // Perform write if enabled
            if (write_en) begin
                ram_mem[addr] <= data_in;
            end

            // Handle read
            // If both read_en & write_en are asserted,
            // we return the newly written data_in instead of stale data.
            if (read_en) begin
                if (write_en) begin
                    data_out <= data_in;  // "write-first" on read-during-write
                end
                else begin
                    data_out <= ram_mem[addr];
                end
            end
            else begin
                data_out <= { (NUM_CHANNELS*DATA_WIDTH){1'b0} };
            end
        end
    end

endmodule
