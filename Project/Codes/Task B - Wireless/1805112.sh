#!/bin/bash

# program starting
echo -e "Wireless Topology Simulation Program starting..."

# nam simulation turned off

# baseline parameters
# baseline_area_dimension=500
baseline_nodes=40
baseline_flows=20
baseline_speed=10
baseline_packets=200

# varying node count
echo -e "Varying node count..."
# creating a file to store the data
rm 1805112_node.txt
touch 1805112_node.txt
for node_count in 20 40 60 80 100
do 
    trace_file="wireless_node_"$node_count".tr"
    nam_file="wireless_node_"$node_count".nam"
    echo -e "Running tcl script"    
    ns 1805112.tcl $node_count $baseline_flows $baseline_packets $baseline_speed $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk $trace_file >> 1805112_node.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 1 1805112_node.txt
echo -e "Python script run complete"

# varying flow count
echo -e "Varying flow count..."
# creating a file to store the data
rm 1805112_flow.txt
touch 1805112_flow.txt
for flow_count in 10 20 30 40 50
do 
    trace_file="wireless_flow_"$flow_count".tr"
    nam_file="wireless_flow_"$flow_count".nam"
    echo -e "Running tcl script"    
    ns 1805112.tcl $baseline_nodes $flow_count $baseline_packets $baseline_speed $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk $trace_file >> 1805112_flow.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 2 1805112_flow.txt
echo -e "Python script run complete"


# varying packet rate
echo -e "Varying packet rate..."
# creating a file to store the data
rm 1805112_packet.txt
touch 1805112_packet.txt
for packet_count in 100 200 300 400 500
do
    trace_file="wireless_packet_"$packet_count".tr"
    nam_file="wireless_packet_"$packet_count".nam"
    echo -e "Running tcl script"    
    ns 1805112.tcl $baseline_nodes $baseline_flows $packet_count $baseline_speed $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk $trace_file >> 1805112_packet.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 3 1805112_packet.txt
echo -e "Python script run complete"

# varying speed
echo -e "Varying node speed..."
# create a file to store the data
rm 1805112_speed.txt
touch 1805112_speed.txt
for node_speed in 5 10 15 20 25
do
    trace_file="wireless_speed_"$node_speed".tr"
    nam_file="wireless_speed_"$node_speed".nam"
    echo -e "Running tcl script"
    ns 1805112.tcl $baseline_nodes $baseline_flows $baseline_packets $node_speed $trace_file $nam_file
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk $trace_file >> 1805112_speed.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 4 1805112_speed.txt
echo -e "Python script run complete"


