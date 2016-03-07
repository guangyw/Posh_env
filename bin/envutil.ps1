# Utility to save and load environment variables in current shell execution context

# TODO: When Save results in override, display the diff of current file vs old file
# TODO: inspect invalid pieces in path, and trim them
# TODO: add more help information here

[CmdletBinding()]
param (
	[Parameter(Mandatory=$true, Position=0)]
	[ValidateSet("Load", "Save", "List")]
	[String]$Action,

	[Parameter(Mandatory=$true, Position=1)]
	[Alias("Path")]
	[String]$EnvironmentFilePath
)

. "$PSScriptRoot\..\lib\FileSys.ps1"

Write-Verbose "Environment file: $EnvironmentFilePath"

if ($Action -eq "Save") {

  if (Test-Path $EnvironmentFilePath) {
    Write-Verbose "Environment file already exists, will override the old one"
  }

  Write-Output "Saving Current Environment to $EnvironmentFilePath"
  ls env: | Export-CliXml -Path $EnvironmentFilePath

} elseif ($Action -eq "Load") {
  $mode = $true
  Write-Output "Loading Environment from $EnvironmentFilePath"

  $envdata = Import-CliXml $EnvironmentFilePath
  $envdata `
  |? {$_.Key -ne "path"} `
  |% {set-item -path "env:$($_.Key)" -value $_.Value }

  $OldPath = $env:Path
  $IncPath = $envdata |? {$_.Key -eq "path"}
  $IncPath = $IncPath.Value
  $mergedPath = Merge-Path $OldPath $IncPath

  Set-Item -Path "env:path" -Value $mergedPath

} elseif ($Action -eq "List") {
  $envdata = Import-CliXml $EnvironmentFilePath
  return $envdata

} else {

  Write-Error "Unrecognized Action '$($Action)'"
}
