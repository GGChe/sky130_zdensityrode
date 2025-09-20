# ---------- SCRIPTS/INNOVUS/report_hooks.tcl ----------
set rptDir RPT
file mkdir $rptDir
set ts [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

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

# (Optional) feed activity if you have it
if {[file exists activity.saif]} { catch { read_saif -input activity.saif } _ }
# if {[file exists activity.vcd]} { catch { read_vcd -file activity.vcd } _ }

# AREA — your build accepts plain 'report_area'
set area_cmds {
  {report_area -hierarchical -physical}
  {report_area -hierarchical}
  {report_area}
  {reportDesignArea}
}
wr_try $area_cmds area_$ts.rpt

# UTILIZATION — your build lacks 'report_utilization'; try common fallbacks
#   - reportFPlan often prints DIE/CORE size and utilization
#   - reportDesignArea sometimes prints utilization summary too
set util_cmds {
  {report_utilization}
  {report_utilization -summary}
  {reportFPlan}
  {reportDesignArea}
}
wr_try $util_cmds utilization_$ts.rpt

# POWER — try both snake_case and camelCase forms
set pwr_sum_cmds {
  {report_power -summary}
  {report_power}
  {reportPower -summary}
  {reportPower}
}
wr_try $pwr_sum_cmds power_summary_$ts.rpt

set pwr_hier_cmds {
  {report_power -hierarchical}
  {report_power}
  {reportPower -hierarchical}
  {reportPower}
}
wr_try $pwr_hier_cmds power_hier_$ts.rpt

# TIMING — keep trying variants
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

# Congestion (if present)
wr_try {{reportCongestion}} congestion_$ts.rpt
# -------------------------------------------------------
