# Startup script for Regular PowerShell environment

Push-Location $PsScriptRoot
$StartupScript = $PsCommandPath

. ".\Profile.ps1"

$repos = "d:\dev\repos"

# ---- UI Related -----

$Host.UI.RawUI.WindowTitle = "PS"
newline "Welcome to Posh-Env"

Pop-Location
Push-Location $Workspace
