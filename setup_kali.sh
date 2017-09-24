chmod +x update.sh
mv update.sh /usr/bin/update

rm /etc/apt/sources.list
echo deb https://http.kali.org/kali kali-rolling main non-free contrib > /etc/apt/sources.list
update