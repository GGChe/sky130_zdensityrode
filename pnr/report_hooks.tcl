
# ---------- report_hooks.tcl ----------
# Ensure report directory exists
set rptDir RPT
file mkdir $rptDir

# Timestamped filenames to avoid overwrites
set ts [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

# Helper proc: run command and redirect stdout to file in RPT/
proc wr {cmd fname} {
  puts "==> Writing $fname"
  eval "$cmd > $::rptDir/$fname"
}

# If you have activity (optional): pick up SAIF/VCD for realistic dynamic power
# Try SAIF first; customize instance path as needed.
if {[file exists activity.saif]} {
  catch { read_saif -input activity.saif } msg
  puts "read_saif: $msg"
}
# If you have a VCD, you can use:
# if {[file exists activity.vcd]} {
#   catch { read_vcd -file activity.vcd } msg
#   puts "read_vcd: $msg"
# }

# Otherwise Innovus uses vectorless/default toggles. You may tune them (optional):
# set_power_analysis_mode -toggle_rate 0.10 -static_probability 0.2

# Area & Utilization
wr {report_area -hierarchical -physical}           area_$ts.rpt
wr {report_utilization}                            utilization_$ts.rpt

# Power (summary + hierarchical breakdown)
wr {report_power -summary}                         power_summary_$ts.rpt
wr {report_power -hierarchical}                    power_hier_$ts.rpt

# Timing (handy context)
wr {report_timing -delay_type max -max_paths 50}   timing_setup_$ts.rpt
wr {report_timing -delay_type min -max_paths 50}   timing_hold_$ts.rpt

# Congestion (optional)
catch { wr {reportCongestion} congestion_$ts.rpt }
# --------------------------------------
