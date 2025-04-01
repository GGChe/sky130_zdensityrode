module processing_system #(
    parameter NUM_UNITS = 16
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire [16*NUM_UNITS-1:0]      data_in,
    input  wire [16*NUM_UNITS-1:0]      threshold_in_array,
    input  wire [7:0]                   class_a_thresh_in,
    input  wire [7:0]                   class_b_thresh_in,
    input  wire [15:0]                  timeout_period_in,
    output wire [NUM_UNITS-1:0]         spike_detection_array,
    output wire [2*NUM_UNITS-1:0]       event_out_array
);

    // Internal signals
    wire [NUM_UNITS-1:0] spike_detection_internal;
    wire [2*NUM_UNITS-1:0] event_out_internal;

    // RAM signals
    reg ram_write_en;
    reg ram_read_en;
    wire ram_full;
    wire [16*NUM_UNITS-1:0] ram_data_out;

    // Data slicing arrays
    wire [15:0] data_in_array [0:NUM_UNITS-1];
    wire [15:0] ram_data_array [0:NUM_UNITS-1];

    integer idx;

    // Slice flattened input data to array
    generate
        for (genvar i = 0; i < NUM_UNITS; i = i + 1) begin
            assign data_in_array[i] = data_in[16*(i+1)-1 : 16*i];
            assign ram_data_array[i] = ram_data_out[16*(i+1)-1 : 16*i];
        end
    endgenerate

    // RAM instance
    ram_unit #(
        .N_CHANNELS(NUM_UNITS),
        .DATA_WIDTH(16*NUM_UNITS)
    ) ram_inst (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),  // Writes entire array for generalization
        .write_en(ram_write_en),
        .read_en(ram_read_en),
        .ram_full(ram_full),
        .data_out(ram_data_out)
    );

    // Generate processing units
    generate
        for (genvar j = 0; j < NUM_UNITS; j = j + 1) begin : processing_units
            processing_unit processing_unit_inst (
                .clk(clk),
                .rst(rst),
                .data_in(ram_data_array[j]),
                .threshold_in(threshold_in_array[16*(j+1)-1 : 16*j]),
                .class_a_thresh_in(class_a_thresh_in),
                .class_b_thresh_in(class_b_thresh_in),
                .timeout_period_in(timeout_period_in),
                .spike_detection(spike_detection_internal[j]),
                .event_out(event_out_internal[2*(j+1)-1 : 2*j])
            );
        end
    endgenerate

    // RAM Write Control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ram_write_en <= 1'b0;
        end else begin
            ram_write_en <= 1'b1;  // Always enabled after reset
        end
    end

    // RAM Read Control
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ram_read_en <= 1'b0;
        end else if (ram_full) begin
            ram_read_en <= 1'b1;
        end
    end

    // Map internal signals to outputs
    assign spike_detection_array = spike_detection_internal;
    assign event_out_array = event_out_internal;

endmodule
