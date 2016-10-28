## A collection of base environment variables
# System envs
# User envs

## Implement the logic for environment switch
# e.g. for a pre-defined set of environment (with enlistments correspondence),
# it is trival to switch to any of them instantly (with switch back logic)

function Add-Path {
  param(
    [Parameter(mandatory=$true)]
    [string]$path
  )
  if (-not (Test-Path $path -PathType Container)) {
    Write-Error "Path does not exist $path"
    return
  }

  $fullPath = (Get-Item $path).FullName

  Write-Verbose "Add $fullPath to local path"
  $env:Path = "$env:Path;$fullPath"
}
