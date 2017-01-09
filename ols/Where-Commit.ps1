# Where is my commit

# TODO: VSTS integration
# Release ID, deployed to INT / EDog / Prod

param (
  [Parameter(Mandatory=$true)]
  [string]$CommitHash
)

$commitSummary = git show --oneline $CommitHash 2>&1

if ($LastExitCode -eq 128) {
  Write-Host $commitSummary[0] -ForegroundColor Red
  Write-Host "Consider pull the latest changes from ``develop`` branch"
  Exit
}

Write-Host $commitSummary[0]

$deployedBuilds = Get-DeployedBuilds

function Get-BuildNumberByServicePool {
  $ServicePoolToken = $args[0]

  $deployedBuilds `
  |? {$_.ServicePool -match $ServicePoolToken } `
  | Select -First 1 -Expand BuildNumber
}

$buildNumbers = @{
  Int = Get-BuildNumberByServicePool "Int"
  EDog = Get-BuildNumberByServicePool "EDog"
  NCUS000 = Get-BuildNumberByServicePool "NCUS-000-Prod"
  NCUS001 = Get-BuildNumberByServicePool "NCUS-001-Prod"
  NCUSZZZ = Get-BuildNumberByServicePool "NCUS-ZZZ-Prod"
  WUS = Get-BuildNumberByServicePool "WUS-Prod"
  SCUS = Get-BuildNumberByServicePool "SCUS-Prod"
}

# Write-Output $buildNumbers

git tag --contains $CommitHash `
|? {-not ($_ -match "Temp")} `
|? {-not ($_ -match "DRAFT")} `
| Select -First 3 `
|% {
  $BuildId, $BuildNumber = $_ -split '_'
  [PsCustomObject] @{
    BuildId = $BuildId
    BuildNumber = $BuildNumber
    # URL = "https://office.visualstudio.com/CLE/OLS%20-%20Office%20Licensing%20Service/_build/index?buildId=$BuildId"
    Int = if ($buildNumbers.Int -ge $buildNumber) { "Yes" } else { "No" }
    EDog = if ($buildNumbers.EDog -ge $buildNumber) { "Yes" } else { "No" }
    'NCUS-000' = if ($buildNumbers.NCUS000 -ge $buildNumber) { "Yes" } else { "No" }
    'NCUS-001' = if ($buildNumbers.NCUS001 -ge $buildNumber) { "Yes" } else { "No" }
    'NCUS-ZZZ' = if ($buildNumbers.NCUSZZZ -ge $buildNumber) { "Yes" } else { "No" }
    WUS = if ($buildNumbers.WUS -ge $buildNumber) { "Yes" } else { "No" }
    SCUS = if ($buildNumbers.SCUS -ge $buildNumber) { "Yes" } else { "No" }
  }
}
