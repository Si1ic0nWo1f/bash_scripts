#!/bin/bash

SAMPLES=~/Desktop/YARA_Samples
RULE=yarGen_Rule.yar
GIT=~/git

if [ ! -d $GIT ]
then
        mkdir $GIT
fi

if [ ! -d $GIT/yarGen ]
then
        cd $GIT && git clone https://github.com/Neo23x0/yarGen && pip install scandir && pip install lxml && pip install naiveBayesClassifier && pip install pefile
fi

if [ ! -d $SAMPLES ]
then
        mkdir $SAMPLES
fi

if [ -e $SAMPLES/$RULE ]
then
	rm $SAMPLES/$RULE
fi

if [ ! -d $GIT/yarGen/dbs ]
then
        cd $GIT/yarGen && python $GIT/yarGen/yarGen.py --update
fi

clear

echo -e "\e[1;92m-----------------------------------------------"
echo -e "\e[0myarGen - YARA rule creation Script"
echo ""
echo "Powered by https://github.com/Neo23x0/yarGen"
echo -e "\e[1;92m-----------------------------------------------"
echo ""

echo -e "\e[1;92mCopy Malware binaries to ~/Desktop/YARA_Samples "
read -p "Press [Enter] key to Continue..." && echo ""

if [ ! "$(ls -A $SAMPLES)" ]
then
	echo -e "\e[1;31mThe YARA Samples Folder is Empty" && read -p "Press [Enter] key to Quit..." && exit
fi

echo -ne "\e[1;92mEnter name for the rule author field: \e[0m"
read author
echo ""

echo "Generating YARA rule..."
echo "This may take several minutes..."

python $GIT/yarGen/yarGen.py -p "CTIC_591SU" -a "$author" -r "Cyber Threat Intelligence Cell, 591SU" -m $SAMPLES -o $SAMPLES/$RULE > /dev/null

clear

if [ ! -e $SAMPLES/$RULE ]
then
        echo "" && echo -e "\e[1;31mAn error occured. The YARA rule wasn't created" && read -p "Press [Enter] key to Quit..." && exit
fi

echo -e "\e[1;92mThe YARA rule was successfully generated"
echo ""
echo -n "Do you want to view the rule? (y/n) \e[0m"
read view
if echo "$view" | grep -iq "^y"
then
	clear&&cat $SAMPLES/$RULE
fi

echo ""
echo -ne "\e[1;92mDo you want to test the rule? (y/n) \e[0m"
read TEST
if echo "$TEST" | grep -iq "^y"
then
        clear&&yara $SAMPLES/$RULE $SAMPLES -r
fi
