
$PsEnvRoot = (Get-Item (Split-Path $PSScriptRoot -Parent)).FullName

. $PsScriptRoot\..\config\ManageConfig.ps1

function Write-Logo {
  # TODO: Colorize this logo

  Write-Host @"
    _______     ______
   / ___  /____/ ____/___ __   __
  / /__/ /  ___/ __/ / __ \ | / /
  /   ___(__  ) /___/ / / | |/ /
 /___/  {_____/____/_/ /_/|___/ !
"@

}
