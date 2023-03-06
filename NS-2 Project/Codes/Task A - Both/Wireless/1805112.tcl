# ======================================================================
# Define options for Wireless 802.11 (mobile) nodes
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type, handles metadata like transmission power, wavelength, etc.
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type for data link protocol
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(rp)             AODV                       ;# routing protocol

# ======================================================================
# Global variables and Variable parameters
# ======================================================================

# creating simulator object
set ns [new Simulator]

# getting command line arguments
# set val(ln) [lindex $argv 0]  ;# area dimension
set val(ln) 500
set val(nn) [lindex $argv 0]  ;# number of mobilenodes
set val(nf) [lindex $argv 1]  ;# number of flows
set val(np) [lindex $argv 2]  ;# number of packets
set val(sn) [lindex $argv 3]  ;# speed of nodes


set val(trace)  [lindex $argv 4]  ;# trace file
set val(nam)    [lindex $argv 5]  ;# nam file

puts "Number of nodes: $val(nn)"
puts "Number of flows: $val(nf)"
puts "Number of packets per second: $val(np)"
puts "Speed of nodes: $val(sn)"

# creating trace file
set trace_file [open $val(trace) w] ;# trace.tr
$ns trace-all $trace_file

# creating nam animation file
set nam_file [open $val(nam) w]    ;# output.nam
$ns namtrace-all-wireless $nam_file $val(ln) $val(ln)

# flat topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(ln) $val(ln)

# general operation director for mobilenodes
create-god $val(nn)

# ======================================================================
# Node configs
# ======================================================================

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF \
                -energyModel "EnergyModel" \
                -rxPower 0.3 \
                -txPower 0.6 \
                -initialEnergy 10

# ======================================================================
# Main program
# ======================================================================

# creating mobile node objects using the above specified configuration 
for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0       ;# disable random motion

    $node($i) set X_ [expr (int(10000 * rand())) % $val(ln) + 0.5]
    $node($i) set Y_ [expr (int(10000 * rand())) % $val(ln) + 0.5]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 17
}

# random movement with uniform random speed between 1 and 5 m/s
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at [expr 10 + int(20 * rand())] "$node($i) setdest [expr (int(10000 * rand())) % $val(ln) + 0.5] [expr (int(10000 * rand())) % $val(ln) + 0.5] $val(sn)"
}

# traffic flow generation
# picking up a random source node
set src [expr (int(10000 * rand())) % $val(nn)]

# picking up a random destination node in loop
for {set i 0} {$i < $val(nf)} {incr i} {
    while {$src == $src} {
        set dst [expr (int(10000 * rand())) % $val(nn)]
        if {$src != $dst} {
            break
        }
    }

    # creating a traffic flow between source and destination
    
    # creating agent (UDP)
    set tcp_source [new Agent/TCP]
    set tcp_sink [new Agent/TCPSink]

    # creating application
    $ns attach-agent $node($src) $tcp_source
    $ns attach-agent $node($dst) $tcp_sink

    $tcp_source set packetSize_ 512
    $tcp_source set window_ $val(np)

    # connecting agents
    $ns connect $tcp_source $tcp_sink

    # marking the flow
    $tcp_sink set fid_ $i

    # setting the application (CBR)
    set ftp [new Application/FTP]

    # attaching the application to the agent
    $ftp attach-agent $tcp_source

    # setting the application parameters
    # $ftp set packetSize_ 512
    # $ftp set interval_ 0.1
    # $ftp set random_ 1
    # $ftp set maxpkts_ 1000

    # starting the application
    $ns at [expr int(9 * rand()) + 1] "$ftp start"
    puts "Flow [expr $i+1]: $src -> $dst"
}

# end of simulation in loop
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}


# closing the trace file and starting nam
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace
    close $nam_file
    close $trace_file
    # exec nam output.nam &
    # exit 0
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

# scheduling the finish procedure
$ns at 50.0001 "finish"
$ns at 50.0002 "halt_simulation"

# starting the simulator
puts "Starting simulation"
$ns run