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

$FsHome = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0"
$FsBinPath = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0\Framework\v4.0"
$CygwinBinPath = "D:\cygwin64\bin\"

Add-Path $FsBinPath

$AtomPath = "C:\Users\hew\AppData\Local\atom\bin"
if (Test-Path $AtomPath) {
    Add-Path $AtomPath
}

if (Test-Path "D:\Apps\Emacs\bin") {
  Add-Path D:\apps\emacs\bin
}

if (Test-Path "D:\Apps\Racket") {
  Add-Path D:\Apps\Racket
}

$env:PathExt += ";.Py"
$env:PathExt += ";.Fsx"
$env:PathExt += ";.FsScript"

$env:Home = (Get-Item "~").FullName

$FsiPath = "$FsBinPath\Fsi.exe"
$FscPath = "$FsBinPath\Fsc.exe"

$MiniCygBin = "D:\Dev\Cygbin"
Set-Alias rlwrap "$MiniCygBin\rlwrap.exe"

function fsi {rlwrap fsi $args}

Set-Alias l ls
Set-Alias posh powershell

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

if (-not $env:VimRuntime) {
  $env:VimRuntime = "D:\Dev\tools\vim80"
}

function Vim { & "$env:VimRunTime\vim.exe" $args }

function GVim { & "$env:VimRunTime\gvim.exe" $args }

function AzCopy { & "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" $args }

function Test-Elevated {
  $adminRole = [Security.Principal.WindowsBuiltInRole]"Administrator";
  return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($adminRole)
}

function Get-HumanReadableSize {
  $bytecount = $args[0]

  switch -Regex ([math]::truncate([math]::log($bytecount,1024))) {
    '^0' {"$bytecount Bytes"}
    '^1' {"{0:n2} KB" -f ($bytecount / 1kb)}
    '^2' {"{0:n2} MB" -f ($bytecount / 1mb)}
    '^3' {"{0:n2} GB" -f ($bytecount / 1gb)}
    '^4' {"{0:n2} TB" -f ($bytecount / 1tb)}
    Default {"{0:n2} PB" -f ($bytecount / 1pb)}
  }
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
