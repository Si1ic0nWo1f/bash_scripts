#!/bin/bash

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

## Add timestamp to changes log
echo >> ../changes.txt && echo  $(datetime) >> ../changes.txt

## Loop to iterate through hosts.txt
while read i; do
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
	grep open ./scans/$(today)-$i-TCPSYN.nmap >> ./ips/$i/open-$i.out
	grep open ./scans/$(today)-$i-UDP.nmap >> ./ips/$i/open-$i.out
	sort ./ips/$i/open-$i.out | uniq > ./ips/$i/open-$i.txt

	## Grep for filtered ports and create unique list
	grep filtered ./scans/$(today)-$i-TCPSYN.nmap >> ./ips/$i/filtered-$i.out
	grep filtered ./scans/$(today)-$i-UDP.nmap >> ./ips/$i/filtered-$i.out
	sort ./ips/$i/filtered-$i.out | uniq > ./ips/$i/filtered-$i.txt

	## Grep for closed ports and create unique list
	grep closed ./scans/$(today)-$i-TCPSYN.nmap | grep -v "are closed" | grep -v "closed ports" >> ./ips/$i/closed-$i.out
	grep closed ./scans/$(today)-$i-UDP.nmap | grep -v "are closed" | grep -v "closed ports" >> ./ips/$i/closed-$i.out
	sort ./ips/$i/closed-$i.out | uniq > ./ips/$i/closed-$i.txt

	## Remove temporary .out files
	rm ./ips/$i/*.out

	## Delete 0 byte files
	cd ips/$i && find ./ -type f -size 0 -print0 | xargs -0 rm && cd ../..
	
	## Compare current and previous xml can files
	cd xml
	ndiff $i-TCPSYN.old-xml $i-TCPSYN.xml 2>/dev/null| grep -v initiated >> ../../changes.txt
	ndiff $i-UDP.old-xml $i-UDP.xml 2>/dev/null| grep -v initiated >> ../../changes.txt
	cd ..

done < ../$filename

## Delete old xml files
cd xml
rm *.old-xml 2>/dev/null

cd ../ips

# Create merged lists for all hosts
grep -rh open >> ../../open_ports.out
grep -rh filtered >> ../../filtered_ports.out
grep -rh closed >> ../../closed_ports.out

cd ../..
sort open_ports.out | uniq > open_ports.txt
sort filtered_ports.out | uniq > filtered_ports.txt
sort closed_ports.out | uniq > closed_ports.txt

## Remove *.out files
rm *.out

## Delete 0 byte files
find ./ -type f -size 0 -print0 | xargs -0 rm
