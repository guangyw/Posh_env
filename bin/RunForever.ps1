
param(
  [Parameter(Mandatory=$true)]
  [string]$Container,

  [ValidateScript({$_ -gt 0})]
  [Parameter(Mandatory=$false)]
  [int]$Count = 10000
)

$CurrentCount = 0
$ContainerName = Split-Path $Container -Leaf
$ActivityName = "Run unit tests - $ContainerName"
$CurrentActivityId = Get-Random

$AllFailures = @()

while ($True) {
  $Results = Run-VSUnitTest $Container

  $Failed = $Results |? {-not $_.Passed}

  if ($Failed) {
    Write-Warning "Test Failed!"
    Write-Warning $Failed
    $AllFailures += @($Failed)

  } else {
    $CurrentCount += 1

    $Percentage = [int]($CurrentCount / $Count * 100)
    Write-Progress -Activity $ActivityName -PercentComplete $Percentage -Id $CurrentActivityId -CurrentOperation $CurrentCount

    if ($CurrentCount -ge $Count)
    {
      Write-Host "Ran for $CurrentCount times, stop"
      Write-Progress -Activity $ActivityName -PercentComplete 100 -Id $CurrentActivityId -Completed
      break
    }
  }
}

return $AllFailures
