#!/bin/bash
cd /var/www/html
sudo wp plugin install --activate "fullwidth-templates" --allow-root
sudo wp plugin install --activate "wpdatatables" --allow-root


# refresh every 15 minutes
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "*/15 * * * * DISPLAY=:0 /home/$USER/refresh.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

