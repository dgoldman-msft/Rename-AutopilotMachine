# Rename-AutopilotMachine

This PowerShell script can be deployed from Intune to enrolled devices to change the machine name. This current script will grab the serial number and system local

**NOTE**: You will need to make modifications to the script on the last line [ line 76] if you want to pass in different parameters to change the logging directory or filename.

> EXAMPLE 1: Rename-AutopilotMachine -Directory "c:\DirectoryName" -File "myfilename.txt"
