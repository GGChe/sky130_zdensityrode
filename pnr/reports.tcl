# Load your signoff checkpoint into memory
restoreDesign DBS/signoff.enc.dat processing_system

# Make sure RPT exists
file mkdir RPT

# Now run reports
report_area > RPT/final_area.rpt

report_power -summary        > RPT/final_power_summary.rpt
report_power -hierarchical   > RPT/final_power_hier.rpt

report_timing -delay_type max -max_paths 50 > RPT/final_timing_setup.rpt
report_timing -delay_type min -max_paths 50 > RPT/final_timing_hold.rpt

# Verify output
exec ls -lh RPT
