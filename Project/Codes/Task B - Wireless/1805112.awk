BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants, tcp header size is 20 bytes
    header_bytes = 20;clear
}


{
    event = $1;
    time_sec = $2;
    node = $3;
    layer = $4;
    packet_id = $6;
    packet_type = $7;
    packet_bytes = $8;
    energy_transmit = $20;
    energy_receive = $22;

    if(event == "D" || event == "r" || event == "s") {
        # remove the first underscore
        sub(/^_*/, "", node);
        sub(/_*$/, "", node);

        # set start time for the first line
        if(start_time > time_sec) {
            start_time = time_sec;
        }

        if (layer == "AGT" && packet_type == "tcp") {
        
            if(event == "s") {
                sent_time[packet_id] = time_sec;
                sent_packets += 1;
                energy_cost[node] = energy_receive + energy_transmit;
            }

            else if(event == "r") {
                delay = time_sec - sent_time[packet_id];    
                total_delay += delay;

                bytes = (packet_bytes - header_bytes);
                received_bytes += bytes;            
                received_packets += 1;
                energy_cost[node] = energy_receive + energy_transmit;
        }
    }

    if (packet_type == "tcp" && event == "D") {
        dropped_packets += 1;
    }

    if(time_sec > end_time)
        end_time = time_sec;
    
    }    
}


END {
    simulation_time = end_time - start_time;
    total_energy = 0;
    node_count = 0;
    for (node in energy_cost) {
        total_energy += energy_cost[node];
        node_count += 1;
    }

    print "Sent Packets: ", sent_packets
    print "Dropped Packets: ", dropped_packets;
    print "Received Packets: ", received_packets;

    print "-------------------------------------------------------------";

    print "Network throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
    print "End-to-end (average) Delay: ", (total_delay / received_packets), "seconds";
    print "Packet delivery ratio: ", (received_packets / sent_packets * 100), "%";
    print "Packet drop ratio: ", (dropped_packets / sent_packets * 100), "%";
    print "Energy consumption: ", total_energy, "Joules";
    
    print "=============================================================";
}