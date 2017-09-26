echo export http_proxy='http://10.0.100.200:8080' >> /etc/profile
echo export https_proxy='http://10.0.100.200:8080' >> /etc/profile
echo export ftp_proxy='http://10.0.100.200:8080' >> /etc/profile
echo""
echo echo -e "Now add \e[1;91mDefaults env_keep = "http_proxy ftp_proxy" \e[0mto the \e[1;91m/etc/sudoers\e[0m file after \e[1;91mDefaults env_reset\e[0m"
