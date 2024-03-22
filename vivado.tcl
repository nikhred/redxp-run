# vivado -mode batch -source script.tcl -tclargs "FPGA=115-2"
package require cmdline
package require try 

source common.tcl 

# Define command line options
set options {
    {f.arg "" "filename - .f file or .sv file"}
    {clk.arg 4.0 "target clock frequency"}
    {part.arg "xczu7ev-ffvc1156-2-e" "part number. Default = xczu7ev-ffvc1156-2-e (one of the free ZU+ boards)"}
    {top.arg "" "name of the top module to be synthesised"}
    {synth.arg "" "generic parameters - passed directly to synth design"}
    {run.arg "impl" "Run Vivado with options. synth and impl for out-of-context mode synthesis and implementation. bts for bitstream generation"}
}

set usage ": vivado.tcl \[options] filename ...\noptions:"
try {
    array set params [::cmdline::getoptions argv $options $usage]
} trap {CMDLINE USAGE} {msg o} {
    # Trap the usage signal, print the message, and exit the application.
    # Note: Other errors are not caught and passed through to higher levels!
    puts $msg
    exit 1
}

# 4 build stages - add elaborate?
# project - create a new project - this uses project mode while the rest of the options use non-project mode
# synth - run out of context synthesis
# impl - run out of context implementation
# bts - run full flow until bitstream generation w/o out-of-context

set run_options [dict create prj 0 synth 1 impl 2 bts 3]
set run [dict get $run_options $params(run)]

set part $params(part)
set files $params(f)
set top $params(top)
set clk $params(clk)
set output_dir build/$top
file mkdir $output_dir

# create_project [‑part <arg>] [‑force] [‑in_memory] [‑ip] [‑rtl_kernel][‑quiet] [‑verbose] [<name>] [<dir>]
set prj_cmd "create_project -quiet -part $part $top $output_dir"

# generate_target [‑force] [‑quiet] [‑verbose] <name> <objects
set generate_cmd "generate_target -verbose all \[get_ips\]"

# synth_design [‑name <arg>] [‑part <arg>] [‑constrset <arg>] [‑top <arg>]
#  [‑include_dirs <args>] [‑generic <args>] [‑define <args>]
#  [‑verilog_define <args>] [‑vhdl_define <args>]
#  [‑flatten_hierarchy <arg>] [‑gated_clock_conversion <arg>]
#  [‑directive <arg>] [‑rtl] [‑lint] [‑file <arg>] [‑bufg <arg>] [‑no_lc]
#  [‑shreg_min_size <arg>] [‑mode <arg>] [‑fsm_extraction <arg>]
#  [‑rtl_skip_mlo] [‑rtl_skip_ip] [‑rtl_skip_constraints]
#  [‑srl_style <arg>] [‑keep_equivalent_registers]
#  [‑resource_sharing <arg>] [‑cascade_dsp <arg>]
#  [‑control_set_opt_threshold <arg>] [‑incremental_mode <arg>]
#  [‑max_bram <arg>] [‑max_uram <arg>] [‑max_dsp <arg>]
#  [‑max_bram_cascade_height <arg>] [‑max_uram_cascade_height <arg>]
#  [‑global_retiming <arg>] [‑no_srlextract] [‑assert] [‑no_timing_driven]
#  [‑sfcu] [‑debug_log] [‑rtl_block_model] [‑quiet] [‑verbose]
set synth_cmd "synth_design -top $top"

# opt_design [‑retarget] [‑propconst] [‑sweep] [‑bram_power_opt] [‑remap]
#  [‑aggressive_remap] [‑resynth_remap] [‑resynth_area]
#  [‑resynth_seq_area] [‑directive <arg>] [‑muxf_remap]
#  [‑hier_fanout_limit <arg>] [‑bufg_opt] [‑mbufg_opt]
#  [‑shift_register_opt] [‑dsp_register_opt] [‑srl_remap_modes <arg>]
#  [‑control_set_merge] [‑control_set_opt] [‑merge_equivalent_drivers]
#  [‑carry_remap] [‑debug_log] [‑property_opt_only] [‑quiet] [‑verbose]
set opt_cmd "opt_design"

# place_design [‑directive <arg>] [‑no_timing_driven] [‑timing_summary]
#  [‑unplace] [‑post_place_opt] [‑no_psip] [‑sll_align_opt] [‑no_bufg_opt]
#  [‑ultrathreads] [‑quiet] [‑verbose]
set place_cmd "place_design"

# route_design [‑unroute] [‑release_memory] [‑nets <args>] [‑physical_nets]
#  [‑pins <arg>] [‑directive <arg>] [‑tns_cleanup] [‑no_timing_driven]
#  [‑preserve] [‑delay] [‑auto_delay] ‑max_delay <arg> ‑min_delay <arg>
#  [‑timing_summary] [‑finalize] [‑ultrathreads] [‑eco] [‑no_psir]
#  [‑quiet] [‑verbose]
set route_cmd "route_design"

set in_memory 0
puts "run option is $params(run)"
if {$params(run) ne "prj"} {
    set in_memory 1
    append prj_cmd " -in_memory"
}

# good to add non ooc impl mode?
set ooc 0 
if {$params(run) ne "bts"} {
    set ooc 1
    append synth_cmd " -mode out_of_context"
}

set dcp 0

if {$params(synth) ne ""} {
    append synth_cmd $params(synth)
}

puts "running $prj_cmd"
eval $prj_cmd

# if -f option is used, use the file given in the option
# else check if synth.f file exists in the output directory - this is generated by the python script
if {[file extension $params(f)] eq ".f"} {
    read_f $params(f)
} elseif {$params(f) != ""} {
    # this option is only to run vivado.tcl directly
    read_rtl $params(f)
} elseif {[file exists $output_dir/synth.f]} {
    read_f $output_dir/synth.f
} else {
    puts "ERROR: no files loaded"
    puts $output_dir/synth.f
}

update_compile_order -fileset sources_1

if {$run > 0} {
    puts "running $synth_cmd"    
    eval $synth_cmd
}

if {$dcp == 1} {
    write_checkpoint -force $output_dir/post_synth.dcp
}

# > $output_dir/synth.log
# this is assuming the clock port is declared as "clk" or starts with clk
if {[get_ports clk] != ""} {
    create_clock -name clk -period $clk [get_ports clk]
} else {
    puts "no clocks found"
}

if {$run > 1} {
    eval $opt_cmd
    eval $place_cmd
    eval $route_cmd
}

if {$dcp == 1} {
    write_checkpoint -force $output_dir/post_route.dcp
}

# TODO: better reporting?
report_utilization -hierarchical > $output_dir/utilization.txt

close [open $output_dir/done a]