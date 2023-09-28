wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/1-base.sh
wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/2-wordpress.sh
wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/3-O365SPOexceldisplay.sh
wget https://raw.githubusercontent.com/rudischmitz71/blahblah/main/4-finalize-tablepi.sh
cp /home/$USER/4-finalize-tablepi.sh /home/$USER/Desktop/4-finalize-tablepi.sh

sudo chmod +x /home/$USER/*.sh

/home/$USER/1-base.sh
/home/$USER/2-wordpress.sh
/home/$USER/3-O365SPOexceldisplay.sh
