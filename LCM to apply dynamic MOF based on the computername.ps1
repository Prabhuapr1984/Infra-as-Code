Param(
    [String]$PullServerURL,
    [String]$PullServerRegistrationKey    
)

[Array]$ServerRoles = @()

switch ($Env:ComputerName)
{
    {$psitem -like "IIS*"} {$ServerRoles += 'IISWeb'}
    {$psitem -like "APP*"} {$ServerRoles += 'AppGeneric'}
    {$psitem -like "SQL*"} {$ServerRoles += 'SQL'}

    Default {$ServerRoles += 'AppGeneric'}
}

[DSCLocalConfigurationManager()]
Configuration StandardLCMConfiguration
{

    [CmdletBinding()]
    Param(
        [String]$PullServerURL,
        [String]$PullServerRegistrationKey,
        [Array]$ConfigNames
    )

    Node localhost
    {
        #: specifies core settings for the LCM agent itself
        Settings
        {
            RefreshMode = 'Pull' # Ensures that the Configuration comes from a Pull Server
            RebootNodeifNeeded = $true # Allows the server to reboot during configuration if required
            ConfigurationMode = 'ApplyandMonitor' # Does not autocorrect. Autocorrect may cause reboots. Logs events instead.
            ActionAfterReboot = 'ContinueConfiguration' # Ensures Configuration re-runs after Server is rebooted
            ConfigurationModeFrequencyMins = '60' # Server checks hourly for new Configuration Files
            RefreshFrequencyMins = '30' # Server will re-evaluate its configuration every 10 hours, avoids too many alerts
            AllowModuleOverwrite = $true # If new module versions  are placed on the server they are downloaded and used
            
        }

        #: specifies an HTTP pull server for configurations.
        ConfigurationRepositoryWeb DefaultPullServer
        {
            ServerURL = $PullServerURL # Specified URL for the Pull Server
            RegistrationKey = $PullServerRegistrationKey # The key used by the machine to identify itself
            ConfigurationNames = $ConfigNames # Supplies the Name of the Configuration to apply
        }
        
        #: specifies an HTTP pull server for modules.
        ResourceRepositoryWeb DefaultModulesServer
        {
            RegistrationKey = $PullServerRegistrationKey # Value for the Client to identify itself to the server
            ServerURL = $PullServerURL # Specific Server URL to communicate with

        }
        
         #: specifies an HTTP pull server to which reports are sent.
        ReportServerWeb DefaultReportServer
        {
            RegistrationKey = $PullServerRegistrationKey # Value for the Client to identify itself to the server
            ServerURL = $PullServerURL # Specific Server URL to communicate with
        }
    }
}

StandardLCMConfiguration -ConfigNames $ServerRoles -PullServerURL 'PullServerURL' -PullServerRegistrationKey 'Registrationkey' -outputpath "c:\temp"

