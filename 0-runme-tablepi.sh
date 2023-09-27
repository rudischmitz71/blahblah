wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/1-base.sh
wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/2-wordpress.sh
wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/3-O365SPOexceldisplay.sh

sudo chmod +x /home/$USER/1-base.sh
sudo chmod +x /home/$USER/2-wordpress.sh
sudo chmod +x /home/$USER/3-O365SPOexceldisplay.sh

/home/$USER/1-base.sh
/home/$USER/2-wordpress.sh
/home/$USER/3-O365SPOexceldisplay.sh
