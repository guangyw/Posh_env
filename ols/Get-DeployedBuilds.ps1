param (
  [Parameter(Mandatory=$false)]
  [ValidateSet("WorldWide", "Gallatin", "BlackForest")]
  $AzureCloud = "WorldWide"
)

# Simple parallelism with PowerShell jobs
# Note that there is an overhead in creating jobs

$ServicePools = Get-ServicePools `
  |? { $_.Cloud -eq $AzureCloud } `
  |% { Start-Job -ArgumentList $_ -ScriptBlock {
          param ( [PsCustomObject] $servicePool )
          $status = Get-DeployedBuild -ServicePoolId $servicePool.ServicePoolId `
                                      -AzureCloud $servicePool.Cloud `
                                      -FastMode

          [PsCustomObject] @{
            ServicePool = $servicePool.Alias
            BuildNumber = $status.BuildNumber
            Status = $status.Status
         }
       }
  } `
  | Wait-Job `
  | Receive-Job

return $ServicePools
