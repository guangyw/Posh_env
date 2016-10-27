# Run bat/cmd file and load the local environment out of it

param(
  [Parameter(Mandatory=$true)]
  [string]$Path
)

. "$PSScriptRoot\..\lib\FileSys.ps1"

# TODO: Produce a diff / summary

$TempFilePath = [System.IO.Path]::GetTempFileName()

Write-Host "Initializing environment with $($Path)" -Foreground Blue

cmd /c "$Path && set > $TempFilePath"

if (-not (Test-Path $TempFilePath)) {
  Write-Error "Cannot find expected temp file $TempFilePath" -Category InvalidData
  return
}

$lines = cat $TempFilePath
Remove-Item -Force $TempFilePath

Write-Host "Importing $($lines.Count) environment variables" -Foreground Blue

foreach ($line in $lines) {
  $name, $value = $line -split '=', 2
  #Write-Host "Overwrite [$name] with $value"
  if ($name -eq "Path") {
    $OldPath = $env:Path
    $IncPath = $value
    $mergedPath = Merge-Path $OldPath $IncPath

    Set-Item -Path "Env:Path" -Value $mergedPath
  } else {

    Set-Item -Path "Env:$name" -Value $value
  }
}
