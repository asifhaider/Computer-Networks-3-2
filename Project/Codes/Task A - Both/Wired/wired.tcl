# Create a simulator object
set ns [new Simulator]

# Set command line arguments
set val(nn) [lindex $argv 0]    ;# Number of nodes
set val(nf) [lindex $argv 1]    ;# Number of flows
set val(np) [lindex $argv 2]    ;# Number of packets

set val(trace)  [lindex $argv 3]  ;# trace file
set val(nam)    [lindex $argv 4]  ;# nam file

puts "Number of nodes: $val(nn)"
puts "Number of flows: $val(nf)"
puts "Number of packets per second: $val(np)"

# Open the NAM file and trace file
set nam_file [open $val(nam) w]
set trace_file [open $val(trace) w]
$ns namtrace-all $nam_file
$ns trace-all $trace_file

# Define a 'finish' procedure
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace 
    # Close the NAM trace file
    close $nam_file
    close $trace_file
    # Execute NAM on the trace file
    # exec nam out.nam 
    exit 0
}

# ======================================================================

for {set i 0} {$i < $val(nn)} {incr i} {
    # Create a node
    set node($i) [$ns node]
}

# Setup bottle neck link
$ns duplex-link $node(0) $node([expr $val(nn)-1]) 2Mb 50ms DropTail

# Setup other links
for {set i 1} {$i < [expr $val(nn)/2]} {incr i} {
    $ns duplex-link $node($i) $node(0) 10Mb 50ms DropTail
}

for {set i [expr $val(nn)/2]} {$i < [expr $val(nn)-1]} {incr i} {
    $ns duplex-link $node([expr $val(nn)-1]) $node($i) 10Mb 50ms DropTail
}

# ======================================================================

# Setup flows

expr {srand(61)}
# setup flows
for {set i 0} {$i < $val(nf)} {incr i} {
    set src [expr int(rand()*$val(nn)/2)]
    set dest [expr int(rand()*$val(nn)/2)+$val(nn)/2-1]
    while {$dest == $src} {
        set dest [expr int(rand()*$val(nn)/2)+$val(nn)/2-1]
    }
    set tcp_($i) [new Agent/TCP]
    set sink_($i) [new Agent/TCPSink]
    $ns attach-agent $node($src) $tcp_($i)
    $ns attach-agent $node($dest) $sink_($i)

    $tcp_($i) set packetSize_ 1000
    $tcp_($i) set window_ $val(np) ;# no. of packet per second, window size

    $ns connect $tcp_($i) $sink_($i)
    $tcp_($i) set fid_ $i

    set ftp_($i) [new Application/FTP]
    $ftp_($i) attach-agent $tcp_($i)

    $ns at 0.1 "$ftp_($i) start"
    $ns at 20.0 "$ftp_($i) stop"
    puts "Flow $i: $src -> $dest"
}

# ======================================================================


#Call the finish procedure after 30 seconds of simulation time
$ns at 30.0 "finish"

#Run the simulation
$ns run