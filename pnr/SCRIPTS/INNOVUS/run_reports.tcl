# SCRIPTS/INNOVUS/run_reports.tcl

# Try to restore the last checkpoint; adjust the glob/path to your flow
set restored 0
foreach db [lsort -decreasing [glob -nocomplain make/*/*.enc.dat]] {
  if {![catch {restoreDesign $db}]} { set restored 1; break }
}
if {!$restored} {
  puts "WARN: No .enc.dat found under make/*/. If you only have DEF/netlist, adapt init_design here."
  # Example fallback (edit to your paths):
  # init_design -top processing_system \
  #   -netlist ./results/final_netlist.v \
  #   -sdc     ./results/final_constraints.sdc \
  #   -def     ./results/final.def
}

# Generate reports
source ./report_hooks.tcl
exit
