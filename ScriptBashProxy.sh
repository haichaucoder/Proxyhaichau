#!/bin/bash

# Check if the user has root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install 3proxy
apt-get update
apt-get install -y 3proxy

# Generate random credentials
username="haichaumobile"
password="2022"

# Get the type of proxy from user input
echo "Enter 1 for HTTP proxy or 2 for Socks5 proxy:"
read proxy_type

# Set the configuration based on the selected proxy type
if [ "$proxy_type" == "1" ]; then
  proxy_type="http"
  config="http"
else
  proxy_type="socks5"
  config="socks"
fi

# Create IP addresses
ip4=$(ip addr | grep 'inet' | grep -v 'inet6' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1)

# Set up firewall rules
ufw allow 8080/tcp

# Configure the proxy server
echo "daemon
maxconn 100
nserver $ip4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
auth strong
$config $ip4:8080 $username $password" > /etc/3proxy/3proxy.cfg

# Start the proxy server
systemctl start 3proxy

# Create a file to store the credentials
echo "$ip4:8080:$username:$password" > proxy_credentials.txt

# Compress the file
zip proxy_credentials.zip proxy_credentials.txt

# Upload the file to transfer.sh
curl --upload-file proxy_credentials.zip https://transfer.sh/proxy_credentials.zip

# Get the download link and password for the file
echo "The proxy credentials can be downloaded from the following link:"
echo "$(curl -s https://transfer.sh/proxy_credentials.zip | awk '{print $2}')"
echo "The password is: $password"
