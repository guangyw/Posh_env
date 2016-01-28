# Utility to save and load environment variables in current shell execution context

# TODO: When Save results in override, display the diff of current file vs old file

[CmdletBinding()]
param (
	[Parameter(Mandatory=$true, Position=0)]
	[ValidateSet("Load", "Save")]
	[String]$Action,

	[Parameter(Mandatory=$true, Position=1)]
	[Alias("Path")]
	[String]$EnvironmentFilePath
)

function Merge-Path($oldpath, $newpath)
{
  $dict = New-Object System.Collections.Generic.HashSet[string]
  $oldpath -split ";" |% {$dict.Add($_) | Out-Null }
  $newpath -split ";" |% {$dict.Add($_) | Out-Null }
  $mergedPath = $dict -join ";"

  Write-Verbose "Merged Path:"
  Write-Verbose $mergedPath

  return $mergedPath
}

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
  $envdata |? {$_.Key -ne "path"} |% {set-item -path "env:$($_.Key)" -value $_.Value }

  $oldPath = $env:Path
  $newPath = $envdata |? {$_.Key -eq "path"}
  $newPath = $newPath.Value
  $mergedPath = Merge-Path($oldPath, $newPath)

  Set-Item -Path "env:path" -Value $mergedPath

} else {

  Write-Error "Unrecognized Action '$($Action)'"
}
