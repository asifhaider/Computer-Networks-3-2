BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants, tcp header size is 20 bytes
    header_bytes = 20;
}


{
    event = $1;
    time_sec = $2;
    from = $3;
    to = $4;
    packet_type = $5;
    packet_bytes = $6;
    src = $9;
    dest = $10; 
    packet_id = $12;

    # sub(/^_*/, "", node);
	# sub(/_*$/, "", node);

    source = int(src);
    destination = int(dest);

    # set start time for the first line
    if(start_time > time_sec) {
        start_time = time_sec;
    }

    if(end_time < time_sec) {
        end_time = time_sec;
    }

    if (packet_type == "tcp") {
        
        if(event == "+" && from == source) {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }

        if(event == "r" && to == destination) {
            delay = time_sec - sent_time[packet_id];
            
            total_delay += delay;

            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;
            received_packets += 1;
        }

        if(event == "d") {
            dropped_packets += 1;   
        }
    }

}


END {
    end_time = time_sec;
    simulation_time = end_time - start_time;

    print "Sent Packets: ", sent_packets;
    print "Dropped Packets: ", dropped_packets;
    print "Received Packets: ", received_packets;
    print "Total Delay: ", total_delay;
    print "Received Bytes: ", received_bytes;
    print "Simulation Time: ", simulation_time;

    print "-------------------------------------------------------------";

    print "Network throughput: ", (received_bytes * 8) / (simulation_time * 1024), "kbps";
    print "End-to-end (average) Delay: ", (total_delay / received_packets), "seconds";
    print "Packet delivery ratio: ", (received_packets / sent_packets * 100), "%";
    print "Packet drop ratio: ", (dropped_packets / sent_packets * 100), "%";
    
    print "=============================================================";
}