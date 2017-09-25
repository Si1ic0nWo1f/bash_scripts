echo export http_proxy='http://10.0.100.200:8080' >> /etc/profile
echo export https_proxy='http://10.0.100.200:8080' >> /etc/profile
echo export ftp_proxy='http://10.0.100.200:8080' >> /etc/profile
echo""
echo Now add ***Defaults env_keep = "http_proxy ftp_proxy"*** to the /etc/sudoers file after Defaults env_reset
