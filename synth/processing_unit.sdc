set sdc_version 2.0
set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design processing_unit

# Clock constraint
create_clock -name clk -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_uncertainty -setup 1.0 [get_clocks clk]
set_clock_uncertainty -hold 1.0 [get_clocks clk]

# Input delays (assumed max path delay = 0.0ns from input to flip-flop)
set_input_delay -clock [get_clocks clk] -max 0.0 [get_ports {data_in[*]}]
set_input_delay -clock [get_clocks clk] -max 0.0 [get_ports threshold_in]
set_input_delay -clock [get_clocks clk] -max 0.0 [get_ports class_a_thresh_in]
set_input_delay -clock [get_clocks clk] -max 0.0 [get_ports class_b_thresh_in]
set_input_delay -clock [get_clocks clk] -max 0.0 [get_ports timeout_period_in]
set_input_delay -clock [get_clocks clk] -max 0.0 [get_ports rst]

# Output delays
set_output_delay -clock [get_clocks clk] -max 0.0 [get_ports spike_detection]
set_output_delay -clock [get_clocks clk] -max 0.0 [get_ports event_out]

# Load and driving cell assumptions (simplified)
set_driving_cell -lib_cell sky130_osu_sc_18T_ms__inv_1 -pin Z [all_inputs]
set_load 0.006 [all_outputs]
