# Startup script for Regular PowerShell environment

Push-Location $PsScriptRoot
$PsEnvStartupScript = $PsCommandPath

. ".\Profile.ps1"

Pop-Location

# Init only if the start script is run as the first command
if ($MyInvocation.HistoryId -eq 1) {
  Set-Title "PS"
  Write-Host "Welcome to Posh-Env`n"
  Push-Location $Workspace
}
