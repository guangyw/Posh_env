# Get the currently deployed build number through OBD

param (
  [Parameter(Mandatory=$true)]
  [string]$ServicePoolId,

  [Parameter(Mandatory=$false)]
  [ValidateSet("WorldWide", "Gallatin", "BlackForest")]
  [string]$AzureCloud = "WorldWide",

  [Parameter(Mandatory=$false)]
  [switch]$FastMode
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

function Get-OneInstanceName {
  param ( [string]$AzureCloud )
  if ($AzureCloud -eq "WorldWide") {
    "OlsFrontend_IN_0"
  } else {
    "OlsFederatedFrontend_IN_0"
  }
}

if ($FastMode) {
  $instanceName = Get-OneInstanceName $AzureCloud
  Write-Verbose "Get-DeployedBuild in FastMode, query instance $instanceName"
  $builds = Get-ObdVersion -ServicePoolId $ServicePoolId -AzureEnvironment $AzureEnvironment `
                           -InstanceName $instanceName
} else {
  $builds = Get-ObdVersion -ServicePoolId $ServicePoolId -AzureEnvironment $AzureEnvironment
}

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
