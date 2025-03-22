set s8lib ../sky130_osu_sc_t18/18T_ms/lib

set_db init_lib_search_path $s8lib
set search_path [list "./" ]
lappend search_path $s8lib
lappend search_path "./hdl"

set_db init_hdl_search_path $search_path
read_libs sky130_osu_sc_18T_ms_TT_1P8_25C.ccs.lib 

set my_hdl_files [glob ./hdl/*.v]
if {[llength $my_hdl_files] == 0} {
    puts "ERROR: No Verilog files found in ./hdl"
    exit 1
}

set my_toplevel "processing_unit"

read_hdl -language v2001 $my_hdl_files
# Alternatively:
# analyze -format verilog $my_hdl_files
# elaborate $my_toplevel

elaborate $my_toplevel

# Clock constraints
set my_clock_pin "clk"
set my_clk_freq_MHz 100
set my_period [expr 1000 / $my_clk_freq_MHz]
set my_uncertainty [expr .1 * $my_period]

set find_clock $my_clock_pin
if { $find_clock != [list] } {
    puts "Found clock!"
    set my_clk $my_clock_pin
}

set all_in_ex_clk [remove_from_collection [all_inputs] [get_ports "clk"]]
set all_out [all_outputs]

read_sdc constraints_top.sdc

# Synthesis Efforts
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

write_hdl > mult_seq.vh
write_sdc > mult_seq.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > mult_seq.sdf

# Report Timing
set filename [format "%s%s%s" "reports/" $my_toplevel "_timing.rep"]
redirect $filename { report_timing -nets -nworst 1}
# Report Area
set filename [format "%s%s%s" "reports/" $my_toplevel "_area.rep"]
redirect $filename { report_area}
# Report QoR
set filename [format "%s%s%s" "reports/" $my_toplevel "_qor.rep"]
redirect $filename { report_qor}
# Report Clocks
set filename [format "%s%s%s" "reports/" $my_toplevel "_clocks.rep"]
redirect $filename { report_clocks}
# Report Timing Summary
set filename [format "%s%s%s" "reports/" $my_toplevel "_timing_summary.rep"]
redirect $filename { report_timing_summary}
# Report Power
set filename [format "%s%s%s" "reports/" $my_toplevel "_power.rep"]
redirect $filename { report_power}


# Quit
exit
