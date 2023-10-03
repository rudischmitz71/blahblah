# tablepi
These are shell scripts to turn a Raspberry pi 4+ device into a dashboard for your data on a large screen TV. 
- We using Raspbian 64-bit OS on the pi4 8GB device.
- We use Python, Powershell, Chromium, WordPress, WPDatatables a Wordpress plugin 
- We dowload an Excel file from SharePoint online site or Teams Sharepoint Online.
- Then convert to csv and display it in Wordpress on the locally attached TV. 


This involves using Raspbian on a Raspberry Pi. The device is then modified to behave as digital signage. Nothing but the content is displayed on the screen. Also there is no kiosk service to pay for. It’s Raspbian so it’s fairly secure and doesn’t drop out being maintained like the other Pi based digital signage setups. 

Hardware Items you will need:
- Raspberry Pi4 device with 8GB of RAM. 
- MicroSD card - 16GB MicroSD for the Pi operating system
- Pi power supply
- HDMI cable
- Pi4 case 
- USB keyboard and mouse. This will only be used for initial setup.
- 4K TV with HDMI port 
- Raspbian OS with desktop 64-bit image downloaded
- An Office 365 account with read access to a sharepoint site. Notes: This user does not have need licenses assigned to it. This will not work with an MFA enabled account. just create an unlicensed user, lengthen the password and the go to the Sharepoint Site and add the user to read only part of the site. 

Tablepi - What you get: Pi4 device that shows a web page of an Excel file on the TV. When the excel file is changed in Office365, it will show on the TV after 15 minutes the cronjob on the Pi will download the latest data and display the changes. 


