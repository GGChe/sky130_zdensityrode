# SCRIPTS/INNOVUS/run_reports.tcl

# ---- SET YOUR TOP NAME ONCE HERE ----
set TOP processing_system

# Try signoff→postroute→route→cts→place→init checkpoints
set restored 0
foreach db [list DBS/signoff.enc.dat DBS/postroute.enc.dat DBS/route.enc.dat \
                 DBS/cts.enc.dat DBS/place.enc.dat DBS/init.enc.dat \
                 DBS/signoff.enc DBS/postroute.enc DBS/route.enc \
                 DBS/cts.enc DBS/place.enc DBS/init.enc] {
  if {[file exists $db]} {
    puts "INFO: Restoring $db"
    # Prefer the explicit -design/-session form (required by your tool)
    if {![catch {restoreDesign -design $TOP -session $db} msg]} {
      puts "INFO: Restored checkpoint: $db"
      set restored 1
      break
    } else {
      puts "WARN: restoreDesign failed for $db : $msg"
      # Try legacy positional form as a fallback (older releases)
      if {![catch {restoreDesign $db} msg2]} {
        puts "INFO: Restored checkpoint (legacy syntax): $db"
        set restored 1
        break
      } else {
        puts "WARN: Legacy restore also failed: $msg2"
      }
    }
  }
}

# If no checkpoint, reconstruct from ASCII (edit paths if needed)
if {!$restored} {
  puts "WARN: No checkpoint restored. Trying DEF+netlist+SDC."

  # Auto-discover typical outputs; override with your exact paths if desired
  set NETLIST ""; foreach c [list \
    results/final_netlist.v {*}[glob -nocomplain results/*netlist*.v] \
    {*}[glob -nocomplain make/*/*.v] {*}[glob -nocomplain *.v] ] { if {[file exists $c]} { set NETLIST $c; break } }
  set SDC ""; foreach c [list \
    results/final_constraints.sdc {*}[glob -nocomplain results/*.sdc] \
    {*}[glob -nocomplain make/*/*.sdc] {*}[glob -nocomplain *.sdc] ] { if {[file exists $c]} { set SDC $c; break } }
  set DEF ""; foreach c [list \
    results/final.def {*}[glob -nocomplain results/*.def] \
    {*}[glob -nocomplain make/*/*.def] {*}[glob -nocomplain *.def] ] { if {[file exists $c]} { set DEF $c; break } }

  if {$NETLIST eq "" || $SDC eq "" || $DEF eq ""} {
    puts "ERROR: Missing NETLIST/SDC/DEF. Edit run_reports.tcl to set exact paths."
    exit 1
  }

  puts "INFO: init_design -top $TOP -netlist $NETLIST -sdc $SDC -def $DEF"
  if {[catch {init_design -top $TOP -netlist $NETLIST -sdc $SDC -def $DEF} emsg]} {
    puts "ERROR: init_design failed: $emsg"
    exit 1
  }
}

# Optional: align stack limit (quiet the earlier info message)
# set_global soft_stack_size_limit hard

# Generate reports
source SCRIPTS/INNOVUS/report_hooks.tcl
exit
