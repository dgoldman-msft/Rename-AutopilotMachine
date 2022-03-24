function Rename-AutopilotMachine {
    <#
        .SYNOPSIS
            Rename an autopilot joined machine

        .DESCRIPTION
            Rename an Intune enrolled Autopilot machine using the serial number and locale of the machine

        .PARAMETER Directory
            Path to logging directory

        .PARAMETER File
            Path to logging file

        .EXAMPLE
            Rename-AutopilotMachine

            This will execute the machine rename and reboot the machine

        .EXAMPLE
            Rename-AutopilotMachine -Directory "c:\Directory" -File "renameLog.txt"

            This will execute the machine rename and reboot the machine and create a logging directory called "c:\Directory" and log to a file called "renameLog.txt"

        .NOTES
            If you restart the Microsoft Intune Management Extension service it will force the agent to check for PowerShell Scripts. 
            PowerShell scripts will only run once if succeeded. Intune will do two more attempts to run it only if it fails to install on the first attempt, 
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]
        $Directory = 'C:\PSLogging',

        [string]
        $File = 'MachineRenameLog.txt'
    )
	
    begin { 
        if (-NOT( Test-Path -Path $Directory)) {
            try {
                New-Item -Path $Directory -Type Directory
                Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "Directory not found. Creating $Directory" -Append
            }
            catch {
                Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "ERROR: $_.Exception.Message" -Append
                return
            }

            Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "Starting rename process!" -Append
        }
    }
	
    process {
        Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "Current machine name: $env:COMPUTERNAME" -Append

        $machineInfo = Get-CimInstance Win32_BIOS | Select-Object SerialNumber
        $serialNumber = (($machineInfo.SerialNumber.Substring($machineInfo.SerialNumber.Length - 7, 6)) -replace "-", "") + "-"
        $locale = Get-WinSystemLocale
        $newComputerName = $serialNumber + $locale
        Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "Old machine name: $env:COMPUTERNAME - New machine name: $newComputerName" -Append

        try {
            Rename-Computer -NewName $newComputerName -DomainCredential $credential -Restart -Force
        }
        catch {
            Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "ERROR: $_.Exception.Message" -Append
            return
        }
    }

    end {
        Out-File -FilePath (Join-Path -Path $Directory -ChildPath $File) -Encoding utf8 -InputObject "Finished rename process!" -Append
    }
}
Rename-AutopilotMachine