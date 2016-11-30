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

git tag --contains $CommitHash `
| Select -First 3 `
|% {
  $BuildId, $BuildNumber = $_ -split '_'
  [PsCustomObject] @{
    BuildId = $BuildId
    BuildNumber = $BuildNumber
    URL = "https://office.visualstudio.com/CLE/OLS%20-%20Office%20Licensing%20Service/_build/index?buildId=$BuildId"
  }
}
