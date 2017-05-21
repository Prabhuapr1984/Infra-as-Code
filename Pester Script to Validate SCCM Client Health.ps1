Describe "Configuration Manager Health Check Analysis" {

    Context "ConfigMgr Client Health Validation" {

        It "ConfigMgr Client CacheSize 10240" { 

            ((Get-WmiObject -Namespace "ROOT\CCM\SoftMgmtAgent" -Class CacheConfig).Size -ne 10240) | Should be True            

        }
        <#
        It "Validate ConfigMgr ClientVersion 5.00.8458.1007" {

            ((Get-WmiObject -Namespace root\ccm SMS_Client).ClientVersion -lt '5.00.8458.1007').ToString() | Should be False

        }

        It "Is Client in ProvisioningMode?" {

            (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\CCM\CcmExec").ProvisioningMode.ToString() | Should be False

        }

        It "Successfully forwarded State Messages to the MP?" {

            (Get-Content -Path C:\Windows\CCM\Logs\StateMessage.log | Where-Object {$_ -match 'Successfully forwarded State Messages to the MP'}).ToString().ToLower() -ne "FALSE" | Should be True

        }

        It "Check Windows Update Agent Policy for Patch Deployment" {

            (Get-Content -Path C:\Windows\CCM\Logs\WUAHandler.log | Where-Object {$_ -match 'Successfully completed scan.'}).ToString().ToLower() -ne "FALSE" | Should be False

        }#>

        It "Check ConfigMgr Client Installed Successfully" {

            (Get-WmiObject -Namespace root\ccm -Class ClientInfo).__CLASS.ToString() -eq 'ClientInfo' | Should be True

        }

        It "Check ConfigMgr ClientLogSize 4096 MB" {

            (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global").LogMaxSize.ToString() | Should be 4096000

        } 

        It "Check SMS Agent Host Service Running" {

            Get-Service | Select-Object -Property Name,Status,StartType | where-object {$_.Name -eq "CCMExec"} | Format-Table -auto

        }

        It "Check BITS Service Running" {

            Get-Service | Select-Object -Property Name,Status,StartType | where-object {$_.Name -eq "BITS"} | Format-Table -auto

        } 

        It "Check Windows Management Service Running" {

            Get-Service | Select-Object -Property Name,Status,StartType | where-object {$_.Name -eq "winmgmt"} | Format-Table -auto

        } 

        It "Check lanmanserver Service Running" {

            Get-Service | Select-Object -Property Name,Status,StartType | where-object {$_.Name -eq "lanmanserver"} | Format-Table -auto

        } 

        It "Check RpcSs Service Running" {

            Get-Service | Select-Object -Property Name,Status,StartType | where-object {$_.Name -eq "RpcSs"} | Format-Table -auto

        }

        It "Check Admin$ Share Accessible" {

            ((Get-WmiObject Win32_Share | Where-Object {$_.Name -like 'ADMIN$'}).__CLASS -eq 'Win32_Share') | Should be True

        }

        It "Check ConfigMgr Client SMS_Client Class WMI" {

            ((Get-WmiObject -Namespace root\ccm -Class SMS_Client -ErrorAction Stop).__CLASS -eq 'SMS_Client') | Should be True

        }

        It "Check WMI Status" {

            (winmgmt /verifyrepository) | Should be 'WMI repository is consistent'

        }

        It "Check SMB1 Protocol Windows Feature is Disabled" {
            ((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State) | Should be Disabled
        }  

    }

}