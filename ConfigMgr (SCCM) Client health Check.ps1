Configuration CCMClientHealthCheck
{

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node localhost
    {
        Script CCMClient
        {
            
            GetScript = 
            {
                [System.String]$strResult = 'OK'
                if ((Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='SMS'" -Namespace "root\cimv2") -eq $null)          
			    {
				    # Set the result
				    $strResult = 'NOK'
			    }
			
			    # Return the result array
			    return @{
				    Result = $strResult
			    }  
            }

            SetScript = 
            {
			    
			    if ((Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='SMS'" -Namespace "root\cimv2") -eq $null) 
			    {
                   Invoke-Command -ScriptBlock {\\Sharepath\CCMClient\ccmsetup.exe '/MP:MPSERVER' 'SMSSITECODE=AUTO' 'FSP=FSPServer1'}
                }
            }

            TestScript = 
            {
			    # Declare and define variables
			    [System.Boolean]$bolResult = $true

			    # Check if filter is already configured
			    if ((Get-WmiObject -Query "SELECT * FROM __Namespace WHERE Name='SMS'" -Namespace "root\cimv2") -eq $null) 
			    {
                    # Set the result
                    $bolResult = $false
                }
			
			    # Return the result
			    return  $bolResult
            }
        }

            Service BITS
            {
                Name = "BITS"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Script]CCMClient"
            }

            Service winmgmt
            {
                Name = "winmgmt"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]Bits"
            }

            Service wuauserv
            {
                Name = "wuauserv"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]winmgmt"
            }

            Service lanmanserver
            {
                Name = "lanmanserver"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]wuauserv"
            }

            Service RpcSs
            {
                Name = "RpcSs"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]lanmanserver"
            }

            Service ccmexec
            {
                Name = "ccmexec"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]RpcSs"
            }

            Service lanmanworkstation
            {
                Name = "lanmanworkstation"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]ccmexec"
            }

            Service CryptSvc
            {
                Name = "CryptSvc"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]lanmanworkstation"
            }

            Service PolicyAgent
            {
                Name = "PolicyAgent"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]CryptSvc"
            }

            Service RemoteRegistry
            {
                Name = "RemoteRegistry"
                StartupType = "Automatic"
                State = "Running"
                DependsOn = "[Service]PolicyAgent"
            }

            Registry EnableDCOM
            {
                Ensure = "Present"
                Key = "HKEY_Local_Machine\SOFTWARE\Microsoft\Ole"
                ValueName = "EnableDCOM"
                ValueData = "Y"
                Force = $true
                DependsOn = "[Service]RemoteRegistry"
            }
            
            Registry ProvisioningMode
            {
                Ensure = "Present"
                Key = "HKEY_Local_Machine\SOFTWARE\Microsoft\CCM\CCMEXEC"
                ValueName = "ProvisioningMode"
                ValueData = "False"
                DependsOn = "[Registry]EnableDCOM"
            }

        Script DisableSMB1Protocol
        {
            DependsOn = "[Registry]ProvisioningMode"
            GetScript = 
            {
                [System.String]$strResult = 'OK'
                if ((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State -eq $Disabled)         
			    {
				    # Set the result
				    $strResult = 'NOK'
			    }
			
			    # Return the result array
			    return @{
				    Result = $strResult
			    }  
            }

            SetScript = 
            {
			    
			    if ((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State -eq $Disabled) 
			    {
                   (Disable-WindowsOptionalFeature -Online -FeatureName 'smb1protocol')
                }
            }

            TestScript = 
            {
			    # Declare and define variables
			    [System.Boolean]$bolResult = $true

			    # Check if filter is already configured
			    if ((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State -eq $Disabled) 
			    {
                    # Set the result
                    $bolResult = $false
                }
			
			    # Return the result
			    return  $bolResult
            }
        }

        Registry LanManServerSMB1
        {
          Ensure = "Present"
          Key = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
          ValueName = "SMB1"
          ValueData = "0"
          DependsOn = "[Script]DisableSMB1Protocol"
        }
    }
}

CCMClientHealthCheck -OutputPath C:\Temp

#Start-DscConfiguration -path C:\temp -Force -Verbose -wait


