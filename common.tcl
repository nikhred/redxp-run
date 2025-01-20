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

proc get_generics {input_string} {
    set result ""

    # Use a regular expression to extract parameters in the format KEY=VALUE
    set regex {([A-Za-z]+)=([0-9]+)}
    foreach {fullmatch key value} [regexp -all -inline -nocase $regex $input_string] {
        append result "_[string tolower $key][string tolower $value]"
    }

    # Remove the leading underscore if the result is not empty
    if {[string length $result] > 0} {
        set result [string range $result 1 end]
    }

    return $result
}
