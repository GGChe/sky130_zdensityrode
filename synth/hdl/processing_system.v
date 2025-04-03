module processing_system #(
    parameter NUM_UNITS = 8
)(
    input  wire                         clk,
    input  wire                         rst,
    // Each channel is 16 bits => 8�16=128 bits total
    input  wire [16*NUM_UNITS-1:0]      data_in,
    input  wire [16*NUM_UNITS-1:0]      threshold_in_array,
    input  wire [7:0]                   class_a_thresh_in,
    input  wire [7:0]                   class_b_thresh_in,
    input  wire [15:0]                  timeout_period_in,
    output wire [NUM_UNITS-1:0]         spike_detection_array,
    output wire [2*NUM_UNITS-1:0]       event_out_array
);

    // Internal signals
    wire [NUM_UNITS-1:0]   spike_detection_internal;
    wire [2*NUM_UNITS-1:0] event_out_internal;

    // New wide RAM signals
    reg  [4:0] addr;
    reg        write_en, read_en;
    wire       ram_full;
    wire [(NUM_UNITS*16)-1:0] ram_data_out;

    // Instantiate new wide RAM
    ram_wide #(
        .NUM_CHANNELS(NUM_UNITS),
        .DATA_WIDTH(16),
        .ADDR_WIDTH(5)         // 32 entries
    ) ram_inst (
        .clk      (clk),
        .rst      (rst),
        .data_in  (data_in),   // 8�16=128 bits
        .write_en (write_en),
        .read_en  (read_en),
        .addr     (addr),
        .data_out (ram_data_out),
        .ram_full (ram_full)
    );

    // Generate processing units
    generate
        for (genvar j = 0; j < NUM_UNITS; j = j + 1) begin : processing_units
            processing_unit processing_unit_inst (
                .clk   (clk),
                .rst   (rst),
                // Each channel j gets its own slice from the wide read-out
                .data_in(ram_data_out[16*(j+1)-1 : 16*j]),
                .threshold_in(threshold_in_array[16*(j+1)-1 : 16*j]),
                .class_a_thresh_in(class_a_thresh_in),
                .class_b_thresh_in(class_b_thresh_in),
                .timeout_period_in(timeout_period_in),
                .spike_detection(spike_detection_internal[j]),
                .event_out(event_out_internal[2*(j+1)-1 : 2*j])
            );
        end
    endgenerate

    // Example address control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr       <= 5'd0;
            write_en   <= 1'b0;
            read_en    <= 1'b0;
        end else begin
            // Just as an example, always write
            write_en <= 1'b1;
            // Read after we've started writing
            read_en  <= 1'b1;
            addr     <= addr + 1'b1;
        end
    end

    // Outputs
    assign spike_detection_array = spike_detection_internal;
    assign event_out_array       = event_out_internal;

endmodule
