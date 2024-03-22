proc read_rtl {filename} {
    # Get the file extension
    set file_extension [file extension $filename]
    
    puts "reading $filename"
    if {$file_extension eq ".sv"} {
        read_verilog -sv $filename
    } elseif {$file_extension eq ".v"} {
        read_verilog $filename
    } elseif {$file_extension eq ".xdc"} {
        read_xdc $filename
    } elseif {$file_extension eq ".xci"} {
        read_ip $filename
        
        set ip_name [file rootname [file tail $filename]]
        generate_target all [get_ips $ip_name]
    } elseif {$file_extension eq ".bd"} {
        read_bd $filename
    } else {
        puts "Unsupported file extension for file: $filename"
    }
}

proc read_f {filename} {
    set fp [open $filename r]
    set lines {}

    while {[gets $fp line] != -1} {
        read_rtl $line
    }
    close $fp
}