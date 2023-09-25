#get the website url you want to display on the kiosk

#!/bin/bash
# Ask the user for password to use inside wordpress
#note this doesnt work for MFA enabled users
read -p 'What password for wpdb: ' passvar
read -p 'What sharepoint webiste url example - "https://yourname.sharepoint.com/sites/sitename": ' spovar
read -p 'What Office365 username: ' o365username
read -p 'What Office365 password: ' o365userpassword





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

chromium-browser --new-window --window-position=0,0 --window-size=3840,2160 --incognito ---data-dir=/home/$USER/.config/chromium2 --enable-features=OverlayScrollbar,OverlayScrollbarFlashAfterAnyScrollUpdate,OverlayScrollbarFlashWhenMouseEnter --app="http://localhost" &

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
# get office365 xlsx file
pwsh /home/$USER/getstuff.ps1
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
sudo apt-get update
sudo apt-get install libssl1.1 libunwind8 -y

#install powershell on pi4
sudo apt-get install wget libssl1.1 libunwind8 -y
sudo mkdir -p /opt/microsoft/powershell/7
wget -O /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.3.7/powershell-7.3.7-linux-arm64.tar.gz 
sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
sudo chmod +x /opt/microsoft/powershell/7/pwsh
sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
rm /tmp/powershell.tar.gz
pwsh -Command {Install-Module -Name PnP.PowerShell -Force}

#install python and openpyxl
sudo apt-get install python3 python3-pip
sudo pip3 install openpyxl


#powershell to get file from office365
cat > /home/$USER/getstuff.ps1 << EOL
Remove-Item -Path "/home/$USER/*.xlsx" -Recurse -Force -Confirm:$false
Remove-Item -Path "/home/$USER/*.csv" -Recurse -Force -Confirm:$false
#Config Variables
$SiteURL = "https://yourcompanyname.sharepoint.com/sites/yourSPOsitenamehere"
$FileRelativeURL = "/sites/yoursitenamehere/Shared Documents/yourfilename.xlsx"
$DownloadPath ="/home/$USER/"
$username="accountame@yourdomain.com"
$encpassword = convertto-securestring -String "thisisyoursuperlongPASSWORDtoaccessoffice365" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword

Try {
    #Connect to PNP Online
    Connect-PnPOnline -Url $SiteURL -Credentials $cred 
Get-PnPContext
    
    #powershell download file from sharepoint online
    Get-PnPFile -Url $FileRelativeURL -Path $DownloadPath -AsFile -FileName "yourfilename.xlsx"
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
python /home/$USER/runme.py
#copy to apache folder
sudo cp -f /home/$USER/output.csv  /var/www/html 
sudo chown www-data:www-data /var/www/html/output.csv
EOL


#create python file to change to csv
cat > /home/$USER/runme.py << EOL
# remove line one
import openpyxl
from openpyxl import load_workbook
wb = load_workbook(filename = '/home/$USER/yourfile.xlsx')
ws = wb.active
#ws.unmerge_cells(start_row=1, start_column=1, end_row=1, end_column=10)
#ws.delete_rows(1)
wb.save('/home/$USER/output.xlsx')
#write CSV
## XLSX TO CSV
import openpyxl
import csv
wb = openpyxl.load_workbook('/home/$USER/output.xlsx')
sh = wb.active # was .get_active_sheet()
with open('/home/$USER/output.csv', 'w', newline="") as file_handle:
    csv_writer = csv.writer(file_handle)
    for row in sh.iter_rows(): # generator; was sh.rows
        csv_writer.writerow([cell.value for cell in row])
EOL






sudo reboot
