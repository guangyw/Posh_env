# Startup script for Regular PowerShell environment

Push-Location $PsScriptRoot
$StartupScript = $PsCommandPath

. ".\Profile.ps1"
. ".\RuntimeHelper.ps1" # Experimental

$Repos = "d:\dev\repos"

# ---- UI Related -----

Pop-Location

# Init only if the start script is run as the first command
if ($MyInvocation.HistoryId -eq 1) {
  Set-Title "PS"
  Write-Host "Welcome to Posh-Env`n"
  Push-Location $Workspace
}
