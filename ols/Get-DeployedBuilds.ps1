param (
  [Parameter(Mandatory=$false)]
  [ValidateSet("WorldWide", "Gallatin", "BlackForest")]
  $AzureCloud = "WorldWide"
)

$ServicePools = Get-ServicePools `
  |? { $_.Cloud -eq $AzureCloud } `
  |% {
    $status = Get-DeployedBuild -ServicePoolId $_.ServicePoolId -AzureCloud $_.Cloud
    [PsCustomObject] @{
      ServicePool = $_.Alias
      BuildNumber = $status.BuildNumber
      Status = $status.Status
    }
  }

return $ServicePools
