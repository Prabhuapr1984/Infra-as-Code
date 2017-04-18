Script RenameAdminAccount            
      {
        GetScript = 
        {
            # Declare and define objects
            [system.string]$strResult = 'OK'

		    # Check if administrator account is already configured
            if ((Get-LocalUser -Name 'administrator').Name.Tolower() -eq "administrator")
			{
			    # Set the result
			    $strResult = 'NOK'
				#break
			}

            return @{
                Result = $strResult
            }
        }
        
        SetScript = 
        {

		    # Check if administrator account is already configured
			if ((Get-LocalUser -Name 'administrator').Name.Tolower() -eq "administrator")
			{
                get-localuser -Name 'administrator' | rename-localuser -newname 'Prabu'
            }
        }

        TestScript = {
            # Declare and define objects
            [boolean]$bolResult = $true

		    # Check if administrator account is already configured
			if ((Get-LocalUser -Name 'administrator').Name.Tolower() -eq "administrator")
			{
                # Set the result
                $bolResult = $false
            }
		
		    # Return the result
		    return $bolResult   
         }  
      }
