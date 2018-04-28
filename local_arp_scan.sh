arp-scan -l | awk '{ print $1 }' | strings -7 | grep -vE 'Starting|Interface:' | sort | uniq | tee hosts.txt
