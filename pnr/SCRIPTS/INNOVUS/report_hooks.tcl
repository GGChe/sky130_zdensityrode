# ---------- SCRIPTS/INNOVUS/report_hooks.tcl (robust) ----------
# Output dir
set rptDir RPT
file mkdir $rptDir
set ts [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

# Run a list of alternative commands; write first success to file
proc wr_try {cmd_list fname} {
  foreach cmd $cmd_list {
    puts "==> Trying: $cmd"
    if {![catch {eval "$cmd > $::rptDir/$fname"} emsg]} {
      puts "    OK -> $::rptDir/$fname"
      return 0
    } else {
      puts "    FAIL: $emsg"
    }
  }
  puts "ERROR: All alternatives failed for $fname"
  return 1
}

# Optional: read activity for realistic dynamic power, if present
if {[file exists activity.saif]} {
  catch { read_saif -input activity.saif } msg
  puts "read_saif: $msg"
}
# if {[file exists activity.vcd]} {
#   catch { read_vcd -file activity.vcd } msg
#   puts "read_vcd: $msg"
# }

# AREA (try multiple variants)
set area_cmds {
  {report_area -hierarchical -physical}
  {report_area -hierarchical}
  {report_area}
  {reportDesignArea}
}
wr_try $area_cmds area_$ts.rpt

# UTILIZATION
set util_cmds {
  {report_utilization}
  {report_utilization -summary}
}
wr_try $util_cmds utilization_$ts.rpt

# POWER
set pwr_sum_cmds {
  {report_power -summary}
  {report_power}
}
wr_try $pwr_sum_cmds power_summary_$ts.rpt

set pwr_hier_cmds {
  {report_power -hierarchical}
  {report_power}
}
wr_try $pwr_hier_cmds power_hier_$ts.rpt

# TIMING (setup/hold)
set setup_cmds {
  {report_timing -delay_type max -max_paths 50}
  {report_timing -max_paths 50}
  {report_timing}
}
wr_try $setup_cmds timing_setup_$ts.rpt

set hold_cmds {
  {report_timing -delay_type min -max_paths 50}
  {report_timing -min_paths 50}
  {report_timing}
}
wr_try $hold_cmds timing_hold_$ts.rpt

# CONGESTION (if supported)
wr_try {{reportCongestion}} congestion_$ts.rpt
# ---------------------------------------------------------------
