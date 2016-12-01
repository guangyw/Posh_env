param (
  [Parameter(Mandatory=$true)]
  [ValidateScript({Test-Path $_})]
  [string]$ConEmuSettingPath
)

$Palettes = @(
  "Base16",
  "Cobalt2",
  "ConEmu",
  "Monokai",
  "Solarized",
  "Solarized Git",
  "Solarized (John Doe)",
  "SolarMe",
  "Tomorrow Night",
  "Tomorrow Night Bright",
  "Tomorrow Night Eighties",
  "Twilight",
  "Ubuntu"
)

function Get-RandomPalette {
  $Palettes | Get-Random
}

. $PsScriptRoot\..\config\ManageConfig.ps1

$xPsStartPath = (Get-Item $PsScriptRoot\..\xPsStart.ps1).FullName

$environments = Get-PsEnvironments

foreach ($env in $environments) {
  
  $palette = Get-RandomPalette

  $startupCmd = "*PowerShell.exe -NoExit -new_console:P:'<$palette>' -File '$xPsStartPath' -EnvironmentName $($env.Name)"
}
