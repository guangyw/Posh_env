# Startup script for Regular PowerShell environment

Push-Location $PsScriptRoot
$StartupScript = $PsCommandPath

. ".\Profile.ps1"

$repos = "d:\dev\repos"

# ---- UI Related -----

Set-Title "PS"
Write-Host "Welcome to Posh-Env`n"

Pop-Location
Push-Location $Workspace
