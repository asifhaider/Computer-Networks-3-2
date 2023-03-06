#!/bin/bash

# program starting
echo -e "Program starting..."

# nam simulation turned off

# baseline parameters
baseline_area_dimension=500
baseline_nodes=40
baseline_flows=20

# varying area dimensions
echo -e "Varying area size..."
# creating a file to store the data
rm 1805112.txt
touch 1805112.txt
for area_dimension in 250 500 750 1000 1250
do 
    echo -e "Running tcl script"    
    ns 1805112.tcl $area_dimension $baseline_nodes $baseline_flows
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk trace.tr >> 1805112.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 1
echo -e "Python script run complete"

# varying node count
echo -e "Varying node count..."
# creating a file to store the data
rm 1805112.txt
touch 1805112.txt
for node_count in 20 40 60 80 100
do 
    echo -e "Running tcl script"    
    ns 1805112.tcl $baseline_area_dimension $node_count $baseline_flows
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk trace.tr >> 1805112.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 2
echo -e "Python script run complete"

# varying flow count
echo -e "Varying flow count..."
# creating a file to store the data
rm 1805112.txt
touch 1805112.txt
for flow_count in 10 20 30 40 50
do 
    echo -e "Running tcl script"    
    ns 1805112.tcl $baseline_area_dimension $baseline_nodes $flow_count
    echo -e "Tcl script run complete"
    echo -e "Running awk script"
    awk -f 1805112.awk trace.tr >> 1805112.txt
    echo -e "Awk script run complete"
done
echo -e "Running python script"
python3 1805112.py 3
echo -e "Python script run complete"