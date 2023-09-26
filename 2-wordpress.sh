#!/bin/bash
#get the website url you want to display on the kiosk
# Ask the user for password to use inside wordpress
read -p 'What password for wpdb: ' passvar

## install Wordpress locally
sudo apt install apache2 -y
sudo apt install php -y
cd /var/www/html/
sudo rm index.html
sudo apt install mariadb-server php-mysql -y

sudo rm /var/www/html/index.html
cd /var/www/html/
ls
sudo wget http://wordpress.org/latest.tar.gz
sudo tar xzf latest.tar.gz
ls
sudo mv wordpress/* .
ls
sudo rm -rf wordpress latest.tar.gz
sudo chown -R www-data: /var/www/html/
# secure mariadb installation
read -p "now running mariadb secure install script. Press any key to resume ..."
sudo mysql_secure_installation

sudo mysql -e "CREATE DATABASE wordpressdb";
sudo mysql -e "CREATE USER wpuser@localhost IDENTIFIED BY '$passvar'";
sudo mysql -e "GRANT ALL ON wordpressdb.* TO wordpressdb@localhost IDENTIFIED BY '$passvar'";

