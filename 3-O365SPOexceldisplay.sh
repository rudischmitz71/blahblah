#step 2
#display xlsx with wordpress local isntall

#!/bin/bash
# Ask the user for password to use inside wordpress
#note this doesnt work for MFA enabled users or subfolders under sharepoint unless the script is edited.
read -p 'What password for wordpress db: ' passvar
read -p 'What sharepoint website url example - "https://yourname.sharepoint.com/sites/sitename": ' spovar
read -p 'What sharepoint sitename: ' sitenamevar
read -p 'What Office365 username: ' o365username
read -p 'What Office365 password: ' o365userpassword
read -p 'What Office365 filename - filename.xlsx : ' o365filename

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
$SiteURL = "$spovar"
$FileRelativeURL = "/sites/$sitenamevar/Shared Documents/$o365filename"
$DownloadPath ="/home/$USER/"
$username="$o365username"
$encpassword = convertto-securestring -String "$o365userpassword" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword

Try {
    #Connect to PNP Online
    Connect-PnPOnline -Url $SiteURL -Credentials $cred 
Get-PnPContext
    
    #powershell download file from sharepoint online
    Get-PnPFile -Url $FileRelativeURL -Path $DownloadPath -AsFile -FileName "$o365filename"
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







