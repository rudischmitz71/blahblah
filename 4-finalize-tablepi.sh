#!/bin/bash

#install wp-cli wordpress cli and some modules
cd ~
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html
sudo wp plugin install --activate "fullwidth-templates" --allow-root
sudo wp plugin install --activate "wpdatatables" --allow-root

#fix wordpress folder permissions
sudo chown www-data:www-data /var/www/html/wp-content/upgrade/

cd ~
# refresh every 15 minutes
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "*/15 * * * * DISPLAY=:0 /home/$USER/refresh.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

