#!/bin/bash

# Variables
SAMPLES=~/Desktop/YARA_Samples
RULE=yarGen_Rule.yar
GIT=~/git
VERBOSE=0

# Display help and usage information
if [ $1 = "-h" ]
then
        echo "usage: ./yarGen.sh [-h] [-s]"
	echo ""
	echo "-h: display this help file"
	echo "-s <path to alternate samples folder>: Change the default samples location"
	echo "-v: Verbose - Display all output"
	echo ""
	echo "EXAMPLES:"
	echo "  ./yarGen.sh -s /home/user/Desktop/samples"
	echo "  ./yarGen.sh -h"
	exit
fi

# Change default samples directory
if [ $1 = "-s" ]
then
	SAMPLES=$2
fi

# Verbose - Display all output
if [ $1 = "-v" ]
then
	VERBOSE=1
fi


# If git folder doesn't exist then create
if [ ! -d $GIT ]
then
        mkdir $GIT
fi

# If yarGen folder doesn't exist then clone github repostitory and install dependencies
if [ ! -d $GIT/yarGen ]
then
        cd $GIT
	git clone https://github.com/Neo23x0/yarGen
	pip install scandir
	pip install lxml
	pip install naiveBayesClassifier
	pip install pefile
	apt-get install yara -y
fi

# If samples folder doesn't exist then create
if [ ! -d $SAMPLES ]
then
        mkdir $SAMPLES
fi

# If database directory doesn't exist then generate
if [ ! -d $GIT/yarGen/dbs ]
then
        cd $GIT/yarGen
	python $GIT/yarGen/yarGen.py --update
fi

# If previous YARA rule file exists then delete
if [ -e $SAMPLES/$RULE ]
then
	rm $SAMPLES/$RULE
fi

if [ VERBOSE="0" ]
then
	clear
fi

# Main title
echo -e "\e[1;92m-----------------------------------------------"
echo -e "\e[0myarGen - YARA rule creation Script"
echo ""
echo "Powered by https://github.com/Neo23x0/yarGen"
echo -e "\e[1;92m-----------------------------------------------"
echo ""

# Pause to allow files to be copied into the sample folder
echo -e "\e[1;92mCopy Malware binaries to ~/Desktop/YARA_Samples "
read -p "Press [Enter] key to Continue..."
echo ""

# If samples folder is empty display a message and exit
if [ ! "$(ls -A $SAMPLES)" ]
then
	echo -e "\e[1;31mThe YARA Samples Folder is Empty"
	read -p "Press [Enter] key to Quit..."
	exit
fi

# Input for author field
echo -ne "\e[1;92mEnter name for the rule author field: \e[0m"
read author
echo ""

# Message displayed while Python script runs
echo "Generating YARA rule..."
echo "This may take several minutes..."

# Main Python script with STDOUT redirected to /dev/null unless VERBOSE = 1

if [ VERBOSE="0" ]
then
	python $GIT/yarGen/yarGen.py -p "PREFIX HERE" -a "$author" -r "REFERENCE HERE" -m $SAMPLES -o $SAMPLES/$RULE > /dev/null
else
	python $GIT/yarGen/yarGen.py -p "PREFIX HERE" -a "$author" -r "REFERENCE HERE" -m $SAMPLES -o $SAMPLES/$RULE	
fi

if [ VERBOSE="0" ]
then
	clear
fi

echo ""
# If YARA rule file doesn't exist then display error message and exit
if [ ! -e $SAMPLES/$RULE ]
then
	echo -e "\e[1;31mAn error occured. The YARA rule wasn't created"
	read -p "Press [Enter] key to Quit..."
	exit
fi

# Success message
echo -e "\e[1;92mThe YARA rule was successfully generated"
echo ""

# Option to display the generated rule
echo -ne "Do you want to view the rule? (y/n) \e[0m"
read view

if [ VERBOSE="0" ]
then
	clear
fi

# If yes then display rule
if echo "$view" | grep -iq "^y"
then
	cat $SAMPLES/$RULE
fi

# Option to test the rule against the files in the sample folder
echo ""
echo -ne "\e[1;92mDo you want to test the rule? (y/n) \e[0m"
read TEST

if [ VERBOSE="0" ]
then
	clear
fi

# If yes then test rule
if echo "$TEST" | grep -iq "^y"
then
	yara $SAMPLES/$RULE $SAMPLES -r
fi
