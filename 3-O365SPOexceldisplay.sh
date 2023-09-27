#!/bin/bash
#display xlsx with wordpress local install
#note this doesnt work for Office365 MFA enabled users or subfolders under sharepoint unless the script is edited.

read -p 'What sharepoint website url example - "https://yourname.sharepoint.com/sites/sitename": ' spovar
read -p 'What sharepoint sitename: ' sitenamevar
read -p 'What Office365 username: ' o365username
read -p 'What Office365 password: ' o365userpassword
read -p 'What Office365 filename - filename.xlsx : ' o365filename


#install wp-cli wordpress cli and some modules
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp



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
#powershell to get file from office365
echo "Remove-Item -Path \"/home/$USER/*.xlsx\" -Recurse -Force -Confirm:$false" > /home/$USER/getstuff.ps1 
echo "Remove-Item -Path \"/home/$USER/*.csv\" -Recurse -Force -Confirm:$false" >> /home/$USER/getstuff.ps1 
echo "#Config Variables" >> /home/$USER/getstuff.ps1
echo "$SiteURL = \"$spovar\"" >> /home/$USER/getstuff.ps1
echo "$FileRelativeURL = \"/sites/$sitenamevar/Shared Documents/$o365filename\"" >> /home/$USER/getstuff.ps1
echo "$DownloadPath =\"/home/$USER/\"" >> /home/$USER/getstuff.ps1
echo "$username=\"$o365username\"" >> /home/$USER/getstuff.ps1
echo "$encpassword = convertto-securestring -String \"$o365userpassword\" -AsPlainText -Force" >> /home/$USER/getstuff.ps1 
echo "$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword" >> /home/$USER/getstuff.ps1
echo "Connect-PnPOnline -Url $SiteURL -Credentials $cred " >> /home/$USER/getstuff.ps1
echo "Get-PnPContext" >> /home/$USER/getstuff.ps1
echo "#powershell download file from sharepoint online" >> /home/$USER/getstuff.ps1
echo "Get-PnPFile -Url $FileRelativeURL -Path $DownloadPath -AsFile -FileName \"$o365filename\"" >> /home/$USER/getstuff.ps1 
echo "#edit xlsx file and get to csv" >> /home/$USER/getstuff.ps1
echo "python /home/$USER/runme.py" >> /home/$USER/getstuff.ps1
echo "#copy to apache folder" >> /home/$USER/getstuff.ps1
echo "sudo cp -f /home/$USER/output.csv /var/www/html" >> /home/$USER/getstuff.ps1
echo "sudo chown www-data:www-data /var/www/html/output.csv" >> /home/$USER/getstuff.ps1

# create python file to change to excel contents around if needed and save as csv
cat > /home/$USER/runme.py << EOL
import openpyxl
from openpyxl import load_workbook
wb = load_workbook(filename = '/home/$USER/yourfile.xlsx')
ws = wb.active
# UNMERGE CELLS ws.unmerge_cells(start_row=1, start_column=1, end_row=1, end_column=10)
# DELETE A ROW ws.delete_rows(1)
wb.save('/home/$USER/output.xlsx')
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

read -p "After this reboot 1. Setup wordpress. 2. Then run the 4-finalize-tablepi.sh file. Hit any key to continue"
sudo reboot

