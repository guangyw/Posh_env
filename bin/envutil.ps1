function merge-path($oldpath, $newpath)
{
  $dict = New-Object System.Collections.Generic.HashSet[string]
  $oldpath -split ";" |% {$dict.Add($_) | Out-Null }
  $newpath -split ";" |% {$dict.Add($_) | Out-Null }
  $mergedPath = $dict -join ";"
  Write-Host "Merged Path:"
  Write-Host $mergedPath
  return $mergedPath
}

$path = $args[1]
Write-Output "Path: $path"

if ($args[0] -eq "Save") {
  Write-Output "Saving Environment..."

  ls env: | Export-CliXml -Path $path

} elseif ($args[0] -eq "Load") {
  $mode = $true
  Write-Output "Loading Environment..."

  $envdata = Import-CliXml $path
  $envdata |? {$_.Key -ne "path"} |% {set-item -path "env:$($_.Key)" -value $_.Value };

  $oldPath = $env:Path
  $newPath = $envdata |? {$_.Key -eq "path"}
  $newPath = $newPath.Value
  $mergedPath = merge-path($oldPath, $newPath)

  Set-Item -Path "env:path" -Value $mergedPath

} else {

  Write-Output "Unrecognized Action '$($args[0])'"

}


