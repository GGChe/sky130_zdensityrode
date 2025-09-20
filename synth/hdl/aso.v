/*
 * Copyright (c) 2024 Gabriel Galeote-Checa
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module aso (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] data_in,
    input  wire [15:0] threshold_in,
    output reg         spike_detected
);

    // State encoding
    localparam TRAINING  = 1'b0;
    localparam OPERATION = 1'b1;
    reg state;

    // Constants
    localparam integer SAMPLE_RATE_HZ     = 2000;
    localparam integer REFRACTORY_SAMPLES = SAMPLE_RATE_HZ / 4;  // 500 samples

    reg  signed [15:0] x1, x2, x3, x4;
    reg  signed [15:0] aso;
    reg  signed [15:0] threshold;

    // Refractory logic (no declaration-time init; initialize in reset)
    reg        in_refractory;
    reg [31:0] refractory_cnt;

    // Absolute value (2's complement)
    function signed [15:0] abs_val;
        input signed [15:0] val;
        begin
            abs_val = (val < 0) ? -val : val;
        end
    endfunction

    // Synchronous reset (posedge clk)
    always @(posedge clk) begin
        if (rst) begin
            x1 <= 16'sd0;
            x2 <= 16'sd0;
            x3 <= 16'sd0;
            x4 <= 16'sd0;
            aso        <= 16'sd0;
            threshold  <= 16'sd500;
            state           <= TRAINING;
            spike_detected  <= 1'b0;
            in_refractory   <= 1'b0;
            refractory_cnt  <= 32'd0;
        end else begin
            // Shift input samples
            x1 <= x2;
            x2 <= x3;
            x3 <= x4;
            x4 <= $signed(data_in);

            spike_detected <= 1'b0;

            // Refractory logic
            if (in_refractory) begin
                if (refractory_cnt >= REFRACTORY_SAMPLES[31:0]) begin
                    in_refractory  <= 1'b0;
                    refractory_cnt <= 32'd0;
                end else begin
                    refractory_cnt <= refractory_cnt + 32'd1;
                end
            end

            // FSM
            case (state)
                TRAINING: begin
                    threshold <= 16'sd500;   // optional fixed training value
                    state     <= OPERATION;
                end

                OPERATION: begin
                    threshold <= $signed(threshold_in);
                    aso       <= abs_val(x4 - x1);

                    if ((aso > threshold) && !in_refractory) begin
                        spike_detected <= 1'b1;
                        in_refractory  <= 1'b1;
                        refractory_cnt <= 32'd0;
                    end
                end
            endcase
        end
    end

endmodule
