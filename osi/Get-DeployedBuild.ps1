# Get the currently deployed build number through OBD

param (
  [Parameter(Mandatory=$true)]
  [string]$ServicePoolId,

  [Parameter(Mandatory=$false)]
  [ValidateSet("WorldWide", "Gallatin", "BlackForest")]
  [string]$AzureCloud = "WorldWide"
)

if (-not (Get-Module OBD)) {
  if (Get-Module OBD -ListAvailable) {
    Import-Module OBD
  }

  if (-not (Get-Module OBD)) {
    Write-Warning "Cannot find or load OBD module"
    Exit
  }
}

$AzureEnvironment = [Microsoft.Office.Web.Obd.Client.ObdServiceAzureEnvironment]::None
if ($AzureCloud -eq "WorldWide") {
  $AzureEnvironment = [Microsoft.Office.Web.Obd.Client.ObdServiceAzureEnvironment]::AzureCloud
} elseif ($AzureCloud -eq "BlackForest") {
  $AzureEnvironment = [Microsoft.Office.Web.Obd.Client.ObdServiceAzureEnvironment]::AzureGermanyCloud
}

$builds = Get-ObdVersion -ServicePoolId $ServicePoolId -AzureEnvironment $AzureEnvironment

$uniqueBuilds = $builds | Select -Expand Version -Unique | Sort

if (@($uniqueBuilds).Count -eq 1) {
  [PsCustomObject] @{
    BuildNumber = $uniqueBuilds
    Status = "Deployed"
  }
} else {
  [PsCustomObject] @{
    BuildNumber = $uniqueBuilds[-1]
    Status = "Deploying"
    PreviousBuildNumber = $uniqueBuilds[-2]
  }
}
