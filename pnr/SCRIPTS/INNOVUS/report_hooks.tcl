# SCRIPTS/INNOVUS/report_hooks.tcl
set rptDir RPT
file mkdir $rptDir
set ts [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

proc wr {cmd fname} {
  puts "==> Writing $fname"
  eval "$cmd > $::rptDir/$fname"
}

# Optional: activity for realistic dynamic power (comment out if not used)
if {[file exists activity.saif]} { catch { read_saif -input activity.saif } msg; puts "read_saif: $msg" }
# if {[file exists activity.vcd]} { catch { read_vcd -file activity.vcd } msg; puts "read_vcd: $msg" }

wr {report_area -hierarchical -physical}           area_$ts.rpt
wr {report_utilization}                            utilization_$ts.rpt
wr {report_power -summary}                         power_summary_$ts.rpt
wr {report_power -hierarchical}                    power_hier_$ts.rpt
wr {report_timing -delay_type max -max_paths 50}   timing_setup_$ts.rpt
wr {report_timing -delay_type min -max_paths 50}   timing_hold_$ts.rpt
catch { wr {reportCongestion}                      congestion_$ts.rpt }
