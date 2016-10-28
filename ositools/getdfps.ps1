. $PSScriptRoot\..\lib\Utility.ps1

$AppDir = $env:AppDir

if (-not (Test-Path $AppDir)) {
  Write-Warning "DevFabric is not deployed"
  return
}

Get-Process `
|? { $_.Path } `
|? { $_.Path.StartsWith($AppDir) } `
|% {
  [PSCustomObject] @{
    Name = $_.ProcessName
    PID = $_.Id
    WS = Format-Size $_.WorkingSet
    CPU = $_.CPU
    #Path = $_.Path.Substring($AppDir.Length)
  }
}
