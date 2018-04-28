#!/bin/bash

:' 
Place this script in a folder with a file named hosts.txt containing 1 IP address per line.
If only scanning your local broadcast domain add the one liner from https://github.com/SiliconW01f/bash_scripts/blob/master/local_arp_scan.sh
The entire script uses relative file paths so can be located in as many places as required without editing.
It will track port changes, maintain lists of all open, closed and filtered ports, and keep a record of scans ran in the logs.txt file
At present the original scan outputs will only be saved once a day and subsequent scans will overwrite the previous one.
All port information has however already been moved to the open, closed and filtered lists.
'


## Variables
filename=hosts.txt

## Date and time functions
today()
{
	date +"%Y%m%d"
}

datetime()
{
	date +"%Y%m%d %T"
}

clear

## Main title
echo -e "\e[1;92m--------------------"
echo -e "\e[0m Batch NMAP scanner"
echo -e "\e[1;92m--------------------"
echo ""

## Check for hosts.txt
if [ ! -f $filename ]
then
	echo -e "\e[1;31mThe $filename file does not exist"
	read -p "Press [Enter] Key To Quit..."
exit

fi

## If results folder doesn't exist then create
if [[ ! -d results ]]
then
	mkdir results
fi

cd results

## If scans folder doesn't exist then create
if [[ ! -d scans ]]
then
	mkdir scans
fi

## If xml folder doesn't exist then create
if [[ ! -d xml ]]
then
	mkdir xml
fi

## If xml folder doesn't exist then create
if [[ ! -d ips ]]
then
	mkdir ips
fi

PS3="Please choose an option "
select option in TCP UDP TCP_and_UDP
do
	case $option in
		TCP)

## Add timestamp to changes log
echo >> ../log.txt && echo TCP scan started at $(datetime) >> ../log.txt

## Loop to iterate through hosts.txt
while read i; do
	
	echo -e "\e[0m" 
		
	## Rename .xml files to .old-xml
	cd xml && ls $i-TCPSYN.xml 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .xml`.old-xml' - {} && cd ../..

	## TCP SYN scan
	nmap -sS -sV -oN ./results/scans/$(today)-$i-TCPSYN.nmap -oX ./results/xml/$i-TCPSYN.xml $i

	cd results/ips
	mkdir $i 2>/dev/null

	## Rename *.txt to *.old
	cd $i && ls *.txt 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .txt`.out' - {} && cd ../..

	## Grep for open ports and create unique list
	grep open ./scans/$(today)-$i-TCPSYN.nmap | column -t >> ./ips/$i/open-$i.out
	sort ./ips/$i/open-$i.out | uniq > ./ips/$i/open-$i.txt

	## Grep for filtered ports and create unique list
	grep filtered ./scans/$(today)-$i-TCPSYN.nmap | grep -v "are filtered" | column -t >> ./ips/$i/filtered-$i.out
	sort ./ips/$i/filtered-$i.out | uniq > ./ips/$i/filtered-$i.txt

	## Grep for closed ports and create unique list
	grep closed ./scans/$(today)-$i-TCPSYN.nmap | grep -vE 'are closed|closed ports|or closed' | column -t >> ./ips/$i/closed-$i.out
	sort ./ips/$i/closed-$i.out | uniq > ./ips/$i/closed-$i.txt

	## Remove temporary .out files
	rm ./ips/$i/*.out

	## Delete 0 byte files
	cd ips/$i && find ./ -type f -size 0 -print0 | xargs -0 rm && cd ../..
	
	## Compare current and previous xml can files
	cd xml
	ndiff $i-TCPSYN.old-xml $i-TCPSYN.xml 2>/dev/null| grep -v initiated >> ../../log.txt
	cd ..

done < ../$filename

## Delete old xml files
cd xml
rm *.old-xml 2>/dev/null

cd ../ips

# Create merged lists for all hosts
grep -rh open | column -t >> ../../open_ports.out
grep -rh filtered | column -t >> ../../filtered_ports.out
grep -rh closed | column -t >> ../../closed_ports.out

cd ../..
sort open_ports.out | uniq > open_ports.txt
sort filtered_ports.out | uniq > filtered_ports.txt
sort closed_ports.out | uniq > closed_ports.txt

## Remove *.out files
rm *.out

## Delete 0 byte files
find ./ -type f -size 0 -print0 | xargs -0 rm

		break;;

	UDP)

echo >> ../log.txt && echo UDP scan started at $(datetime) >> ../log.txt

## Loop to iterate through hosts.txt
while read i; do

	echo -e "\e[0m" 
	
	## Rename .xml files to .old-xml
	cd xml && ls $i-UDP.xml 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .xml`.old-xml' - {} && cd ../..

	## UDP scan
 	nmap -sU -sV -oN ./results/scans/$(today)-$i-UDP.nmap -oX ./results/xml/$i-UDP.xml $i

	cd results/ips
	mkdir $i 2>/dev/null

	## Rename *.txt to *.old
	cd $i && ls *.txt 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .txt`.out' - {} && cd ../..

	## Grep for open ports and create unique list
	grep open ./scans/$(today)-$i-UDP.nmap | column -t >> ./ips/$i/open-$i.out
	sort ./ips/$i/open-$i.out | uniq > ./ips/$i/open-$i.txt


	## Grep for filtered ports and create unique list
	grep filtered ./scans/$(today)-$i-UDP.nmap | grep -v "are filtered" | column -t >> ./ips/$i/filtered-$i.out
	sort ./ips/$i/filtered-$i.out | uniq > ./ips/$i/filtered-$i.txt

	## Grep for closed ports and create unique list
	grep closed ./scans/$(today)-$i-UDP.nmap | grep -vE 'are closed|closed ports|or closed' | column -t >> ./ips/$i/closed-$i.out
	sort ./ips/$i/closed-$i.out | uniq > ./ips/$i/closed-$i.txt

	## Remove temporary .out files
	rm ./ips/$i/*.out

	## Delete 0 byte files
	cd ips/$i && find ./ -type f -size 0 -print0 | xargs -0 rm && cd ../..
	
	## Compare current and previous xml can files
	cd xml
	ndiff $i-UDP.old-xml $i-UDP.xml 2>/dev/null| grep -v initiated >> ../../log.txt
	cd ..

done < ../$filename

## Delete old xml files
cd xml
rm *.old-xml 2>/dev/null

cd ../ips

# Create merged lists for all hosts
grep -rh open | column -t >> ../../open_ports.out
grep -rh filtered | column -t >> ../../filtered_ports.out
grep -rh closed | column -t >> ../../closed_ports.out

cd ../..
sort open_ports.out | uniq > open_ports.txt
sort filtered_ports.out | uniq > filtered_ports.txt
sort closed_ports.out | uniq > closed_ports.txt

## Remove *.out files
rm *.out

## Delete 0 byte files
find ./ -type f -size 0 -print0 | xargs -0 rm

		break;;

	TCP_and_UDP)

echo >> ../log.txt && echo TCP and UDP scan started at $(datetime) >> ../log.txt

## Loop to iterate through hosts.txt
while read i; do

	echo -e "\e[0m" 

	## Rename .xml files to .old-xml
	cd xml && ls $i-TCPSYN.xml 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .xml`.old-xml' - {} 
	ls $i-UDP.xml 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .xml`.old-xml' - {} && cd ../..

	## TCP SYN scan
	nmap -sS -sV -oN ./results/scans/$(today)-$i-TCPSYN.nmap -oX ./results/xml/$i-TCPSYN.xml $i

	## UDP scan
 	nmap -sU -sV -oN ./results/scans/$(today)-$i-UDP.nmap -oX ./results/xml/$i-UDP.xml $i

	cd results/ips
	mkdir $i 2>/dev/null

	## Rename *.txt to *.old
	cd $i && ls *.txt 2>/dev/null| xargs -I {} sh -c 'mv $1 `basename $1 .txt`.out' - {} && cd ../..

	## Grep for open ports and create unique list
	grep open ./scans/$(today)-$i-TCPSYN.nmap | column -t >> ./ips/$i/open-$i.out
	grep open ./scans/$(today)-$i-UDP.nmap | column -t >> ./ips/$i/open-$i.out
	sort ./ips/$i/open-$i.out | uniq > ./ips/$i/open-$i.txt

	## Grep for filtered ports and create unique list
	grep filtered ./scans/$(today)-$i-TCPSYN.nmap | grep -v "are filtered" | column -t >> ./ips/$i/filtered-$i.out
	grep filtered ./scans/$(today)-$i-UDP.nmap | grep -v "are filtered" | column -t >> ./ips/$i/filtered-$i.out
	sort ./ips/$i/filtered-$i.out | uniq > ./ips/$i/filtered-$i.txt

	## Grep for closed ports and create unique list
	grep closed ./scans/$(today)-$i-TCPSYN.nmap | grep -vE 'are closed|closed ports|or closed' | column -t >> ./ips/$i/closed-$i.out
	grep closed ./scans/$(today)-$i-UDP.nmap | grep -vE 'are closed|closed ports|or closed' | column -t >> ./ips/$i/closed-$i.out
	sort ./ips/$i/closed-$i.out | uniq > ./ips/$i/closed-$i.txt

	## Remove temporary .out files
	rm ./ips/$i/*.out

	## Delete 0 byte files
	cd ips/$i && find ./ -type f -size 0 -print0 | xargs -0 rm && cd ../..
	
	## Compare current and previous xml can files
	cd xml
	ndiff $i-TCPSYN.old-xml $i-TCPSYN.xml 2>/dev/null| grep -v initiated >> ../../log.txt
	ndiff $i-UDP.old-xml $i-UDP.xml 2>/dev/null| grep -v initiated >> ../../log.txt
	cd ..

done < ../$filename

## Delete old xml files
cd xml
rm *.old-xml 2>/dev/null

cd ../ips

# Create merged lists for all hosts
grep -rh open | column -t >> ../../open_ports.out
grep -rh filtered | column -t >> ../../filtered_ports.out
grep -rh closed | column -t >> ../../closed_ports.out

cd ../..
sort open_ports.out | uniq > open_ports.txt
sort filtered_ports.out | uniq > filtered_ports.txt
sort closed_ports.out | uniq > closed_ports.txt

## Remove *.out files
rm *.out

## Delete 0 byte files
find ./ -type f -size 0 -print0 | xargs -0 rm

		break;;

	esac
done
