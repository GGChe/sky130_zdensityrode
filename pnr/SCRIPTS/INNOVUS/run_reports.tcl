# SCRIPTS/INNOVUS/run_reports.tcl

# 1) Restore the final checkpoint (prefer signoff)
set restored 0
foreach db [list DBS/signoff.enc.dat DBS/postroute.enc.dat DBS/route.enc.dat DBS/cts.enc.dat DBS/place.enc.dat DBS/init.enc.dat] {
  if {[file exists $db]} {
    puts "INFO: Restoring $db"
    if {![catch {restoreDesign $db} msg]} {
      set restored 1
      break
    } else {
      puts "WARN: restoreDesign failed for $db : $msg"
    }
  }
}
if {!$restored} {
  puts "ERROR: No checkpoint found in DBS/. Aborting reports."
  exit 1
}

# 2) Generate reports (writes to RPT/)
source SCRIPTS/INNOVUS/report_hooks.tcl
exit
