# -------- SCRIPTS/INNOVUS/run_reports.tcl --------
# Set your top design name here (very likely "processing_system")
set TOP processing_system

# Candidate checkpoints in preferred order
set db_list [list \
  DBS/signoff.enc.dat   DBS/signoff.enc \
  DBS/postroute.enc.dat DBS/postroute.enc \
  DBS/route.enc.dat     DBS/route.enc \
  DBS/cts.enc.dat       DBS/cts.enc \
  DBS/place.enc.dat     DBS/place.enc \
  DBS/init.enc.dat      DBS/init.enc \
]

set restored 0
foreach db $db_list {
  if {[file exists $db]} {
    puts "INFO: Trying restoreDesign $db $TOP"
    # POSitional syntax required by your version: <session> <design>
    if {![catch {restoreDesign $db $TOP} msg]} {
      puts "INFO: Restored checkpoint: $db"
      set restored 1
      break
    } else {
      puts "WARN: restoreDesign failed for $db : $msg"
    }
  }
}

if {!$restored} {
  puts "ERROR: Could not restore any checkpoint from DBS/ using top '$TOP'."
  puts "HINT: Verify the top name in the checkpoint. If it's not '$TOP', set the correct name in this script."
  exit 1
}

# Optional: align soft stack size (silence the earlier info message)
# set_global soft_stack_size_limit hard

# Generate reports into RPT/
source SCRIPTS/INNOVUS/report_hooks.tcl
exit
# -------------------------------------------------
