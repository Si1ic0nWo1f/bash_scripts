echo -n "Enter IP: "
read ip

echo -n "Enter box name: "
read name
mkdir $name

cd $name

nmap -A $ip -vv -oA ${name}_A

###
##open ports
###
grep "tcp open\|tcp  open" ${name}_A.nmap | awk '{ print $1 }' > open_ports_$name.txt

###
## http
###
grep "open  http" ${name}_A.nmap | awk '{ print $1 }' | cut -f1 -d"/" > http_ports_$name.txt

if [[ -f http_ports_$name.txt ]]
then

while read p; do
  nikto -host $ip -port $p | tee nikto_${name}_${p}.txt
  dirb http://$ip:$p | tee dirb_${name}_${p}.txt
  uniscan -u $ip:$p -qweds | tee uniscan_${name}_${p}.txt
done <http_ports_$name.txt

fi

###
## https
###
grep "open  ssl/http" ${name}_A.nmap | awk '{ print $1 }' | cut -f1 -d"/" > https_ports_$name.txt

if [[ -f https_ports_$name.txt ]]
then

while read p; do
  nikto -host $ip -port $p | tee nikto_${name}_${p}.txt
  dirb https://$ip:$p | tee dirb_${name}_${p}.txt
  uniscan -u $ip:$p -qweds | tee uniscan_${name}_${p}.txt
done <https_ports_$name.txt

fi
