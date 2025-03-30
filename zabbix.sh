#!/bin/bash

set -e  # Stop the script if any command fails

echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "Installing PHP and required modules..."
sudo apt install -y php php-mysql php-xml php-bcmath php-mbstring php-gd php-ldap php-net-socket php-fpm php-zip php-cli


echo "Creating MySQL Database for Zabbix..."
sudo mysql -u root -e "
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
"

echo "Adding Zabbix repository..."
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
sudo apt update

echo "Installing Zabbix server, web frontend, and agent..."
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent

echo "Importing initial database schema..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u zabbix -pStrongPassword123 zabbix

echo "Configuring Zabbix Server..."
sudo sed -i 's/# DBPassword=/DBPassword=StrongPassword123/' /etc/zabbix/zabbix_server.conf

echo "Restarting Zabbix and Apache services..."
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

echo "Installation complete! Access Zabbix at http://your-server-ip/zabbix"
