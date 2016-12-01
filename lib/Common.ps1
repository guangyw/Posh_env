
$PsEnvRoot = (Split-Path $PSScriptRoot -Parent).FullName

. $PsScriptRoot\..\config\ManageConfig.ps1




function Write-Logo {

  Write-Host @"
  ____       ______
 / __ \_____/ ____/___ _   __
/ /_/ / ___/ __/ / __ \ | / /
/ ____(__  ) /___/ / / / |/ /
/_/   /____/_____/_/ /_/|___/
"@

}
