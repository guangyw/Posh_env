
[CmdletBinding()]
param (
	[Parameter(Mandatory=$true, Position=0)]
	[ValidateSet("Load", "Save")]
	[String]$Action,

	[Parameter(Mandatory=$true, Position=1)]
	[Alias("Path")]
	[String]$EnvironmentFilePath
)


function merge-path($oldpath, $newpath)
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
  Write-Output "Saving Environment..."

  ls env: | Export-CliXml -Path $EnvironmentFilePath

} elseif ($Action -eq "Load") {
  $mode = $true
  Write-Output "Loading Environment..."

  $envdata = Import-CliXml $EnvironmentFilePath
  $envdata |? {$_.Key -ne "path"} |% {set-item -path "env:$($_.Key)" -value $_.Value };

  $oldPath = $env:Path
  $newPath = $envdata |? {$_.Key -eq "path"}
  $newPath = $newPath.Value
  $mergedPath = Merge-Path($oldPath, $newPath)

  Set-Item -Path "env:path" -Value $mergedPath

} else {

  Write-Error "Unrecognized Action '$($Action)'"

}


