# PowerShell Profile of Odin (hew)

# This Profile will only affect the Windows PowerShell
# Excluding PowerShell Implementation by Others
# Should be fine to put everything here

$UserProfile = "$PsScriptRoot\Profile.ps1"

Push-Location $PsScriptRoot

. ".\lib\Common.ps1"
. ".\lib\Utility.ps1"
. ".\lib\FileSys.ps1"
. ".\lib\EnvLib.ps1"

Add-Path .\bin
Add-Path .\obin
Add-Path .\OSI

$Repos = "d:\dev\repos"

$env:PathExt += ";.Py"

$env:Home = (Get-Item "~").FullName

function fsi {rlwrap fsi $args}

Set-Alias l ls
Set-Alias posh powershell

# git alias
function gs {git status}
function gd {git diff}
function ga {git add}

# Show all files
function lla {ls -Force}

function .. { push-location .. }
function ... { push-location ../.. }
function e. {explorer .}

function which
{
  $cmd = Get-Command $args[0] -ErrorAction Stop
  $def = $cmd | Select -Expand Definition
  $def.Trim()

  <#
  if ($cmd.CommandType -eq [Management.Automation.CommandTypes]::Application)
  {}
  else if ($cmd.CommandType -eq [Management.Automation.CommandTypes]::Function)
  {
    cat "function:Path"
  }
  else
  {
    Write-Error "Unhandled CommandType $($cmd.CommandType)"
  }
  #>
}

function Get-LastDownload
{
  [CmdletBinding()]
  [Alias("getlastdown")]
  param ()

  $downloadLocations = Join-Path $env:USERPROFILE "Downloads"

  $lastDownloadedFile = $downloadLocations `
  | ls -File `
  | Sort LastWriteTime -Descending `
  | Select -First 1

  if ($pwd -eq (Split-Path $lastDownloadedFile -Parent))
  {
      "File already in current folder"
  }

  Write-Host "Get $lastDownloadedFile"
  Move-Item $lastDownloadedFile.FullName $pwd.Path -Force

  return (Get-Item $lastDownloadedFile.Name)
}

function AzCopy { & "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" $args }

function Test-Elevated {
  $adminRole = [Security.Principal.WindowsBuiltInRole]"Administrator";
  return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($adminRole)
}

function CopyPwd {
  $pwd.Path | clip
}

function CopyPath {
    param(
    [string]$path
    )
    if (-not $path) { $path = '.' }
    $absPath = (Get-Item $path).FullName
    echo "Copy $absPath"
    $absPath | clip
}

function devenv15 {
  $devenv15Cmd = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"
  & $devenv15Cmd $args
}

Pop-Location