#get the website url you want to display on the kiosk

#!/bin/bash
# Ask the user for password to use inside wordpress
read -p 'What password for wpdb: ' passvar
echo
echo Thank you we now have website to display on the tv $passvar


#enable ssh server
sudo systemctl enable ssh 
sudo systemctl start ssh
cd ~


#autohide taskbar
sudo sed -i "s/autohide=.*/autohide=1/" /etc/xdg/lxpanel/LXDE-pi/panels/panel 
sudo sed -i "s/heightwhenhidden=.*/heightwhenhidden=0/" /etc/xdg/lxpanel/LXDE-pi/panels/panel

#hide mouse when no movement allow programmed refresh
sudo apt install xdotool unclutter -y


#change setting to openbox
sudo sed -i "s/window_manager=.*/window_manager=openbox/" /etc/xdg/lxsession/LXDE-pi/desktop.conf

# no window border
sudo mkdir ~/.config/openbox
sudo cp /etc/xdg/openbox/rc.xml  ~/.config/openbox/rc.xml
sudo sed -i "s/<keepBorder>yes/<keepBorder>no/" ~/.config/openbox/rc.xml

# no decorations
sudo sed -i "s#</applications>#<application class=\"*\"> <decor>no</decor>  </application> </applications>#" ~/.config/openbox/rc.xml


mkdir /home/$USER/.config/lxsession
mkdir /home/$USER/.config/lxsession/LXDE-pi
cp /etc/xdg/lxsession/LXDE-pi/autostart /home/$USER/.config/lxsession/LXDE-pi/
sudo echo "sh /home/$USER/myscript.sh" >> /home/$USER/.config/lxsession/LXDE-pi/autostart

cat > /home/$USER/myscript.sh << EOL
#!/bin/sh
# what this script does: start chromium

chromium-browser --new-window --window-position=0,0 --window-size=3840,2160 --incognito --user-data-dir=/home/$USER/.config/chromium2 --enable-features=OverlayScrollbar,OverlayScrollbarFlashAfterAnyScrollUpdate,OverlayScrollbarFlashWhenMouseEnter --app="http://localhost" &

EOL

sudo chmod +x /home/$USER/myscript.sh


## black blackground and disable notifications
mkdir /home/$USER/.config/pcmanfm
mkdir /home/$USER/.config/pcmanfm/LXDE-pi
cat > /home/$USER/.config/pcmanfm/LXDE-pi/desktop-items-0.conf << EOL
[*]
desktop_bg=#000000
desktop_shadow=#000000
desktop_fg=#E8E8E8
desktop_font=PibotoLt 12
wallpaper=/usr/share/rpd-wallpaper/clouds.jpg
wallpaper_mode=color
show_documents=0
show_trash=0
show_mounts=0
EOL




# refresh screen local via keyboard emulation
cat >  /home/$USER/refresh.sh  << EOL
#!/bin/sh
# blah blah

WID=$(xdotool search --onlyvisible --class chromium|head -1)
xdotool windowactivate ${WID}
xdotool key ctrl+F5

EOL

sudo chmod +x refresh.sh 

# refresh every 15 minutes
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "*/15 * * * * DISPLAY=:0 /home/$USER/refresh.sh" >> mycron
#install new cron file
crontab mycron
rm mycron


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
sudo mysql_secure_installation

sudo mysql -e "CREATE DATABASE wordpressdb";
sudo mysql -e "CREATE USER wpuser@localhost IDENTIFIED BY '$passvar'";
mysql -e "GRANT ALL PRIVILEGES ON wordpressdb.* TO wordpressdb@localhost IDENTIFIED BY '$passvar'";

sudo reboot
