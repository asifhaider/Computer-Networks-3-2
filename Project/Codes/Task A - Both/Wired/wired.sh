#!/bin/bash

# program starting
echo -e "Wired Topology Simulation Program starting..."

# nam simulation turned off

# baseline parameters
# baseline_area_dimension=500
baseline_nodes=40
baseline_flows=20
baseline_packets=200

# varying node count
echo -e "Varying node count..."
# creating a file to store the data
rm wired_temp.txt
touch wired_temp.txt
for node_count in 20 40 60 80 100
do 
    trace_file="wired_node_"$node_count".tr"
    nam_file="wired_node_"$node_count".nam"
    echo -e "Running tcl script"    
    ns wired.tcl $node_count $baseline_flows $baseline_packets $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f wired.awk $trace_file >> wired_temp.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 wired.py 1
echo -e "Python script run complete"

# varying flow count
echo -e "Varying flow count..."
# creating a file to store the data
rm wired_temp.txt
touch wired_temp.txt
for flow_count in 10 20 30 40 50
do 
    trace_file="wired_flow_"$flow_count".tr"
    nam_file="wired_flow_"$flow_count".nam"
    echo -e "Running tcl script"    
    ns wired.tcl $baseline_nodes $flow_count $baseline_packets $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f wired.awk $trace_file >> wired_temp.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 wired.py 2
echo -e "Python script run complete"

# varying packet rate
echo -e "Varying packet rate..."
# creating a file to store the data
rm wired_temp.txt
touch wired_temp.txt
for packet_count in 100 200 300 400 500
do
    trace_file="wired_packet_"$packet_count".tr"
    nam_file="wired_packet_"$packet_count".nam"
    echo -e "Running tcl script"    
    ns wired.tcl $baseline_nodes $baseline_flows $packet_count $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f wired.awk $trace_file >> wired_temp.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 wired.py 3
echo -e "Python script run complete"
