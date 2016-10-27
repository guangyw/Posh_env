# PowerShell Profile of Odin (hew)

# This Profile will only affect the Windows PowerShell
# Excluding PowerShell Implementation by Others
# Should be fine to put everything here

$UserProfile = "$PsScriptRoot\Profile.ps1"

# TODO: this should be deprecated in favor of Autojump / Z-Location
if ((-not $Workspace) -or -not (Test-Path $Workspace)) {
  foreach ($ws in "d:\dev\workspace", "c:\dev\workspace", "e:\Workspace") {
    if (Test-Path $ws) {
      $Workspace = $ws
      break
    }
  }
}

if (-not $StartupScript)
{
  $StartupScript = $UserProfile
}

Push-Location $PsScriptRoot

. ".\lib\Utility.ps1"
. ".\config\Modules.ps1"

$Repos = "d:\dev\repos"

$FsHome = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0"
$FsBinPath = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0\Framework\v4.0"
$CygwinBinPath = "D:\cygwin64\bin\"
$env:Path += ";$FsBinPath"
#$env:Path = "$CygwinBinPath;" + $env:Path
$env:Path += ";$PsScriptRoot\bin"
$env:Path += ";$PsScriptRoot\obin"

$AtomPath = "C:\Users\hew\AppData\Local\atom\bin"
if (Test-Path $AtomPath) {
    $env:Path += ";$AtomPath"
}

if (Test-Path "D:\Apps\Emacs\bin") {
  $env:Path += ";D:\apps\emacs\bin"
}

if (Test-Path "D:\Apps\Racket") {
  $env:Path += ";D:\Apps\Racket"
}

$env:PathExt += ";.Py"
$env:PathExt += ";.Fsx"
$env:PathExt += ";.FsScript"

$env:Home = (Get-Item "~").FullName

$FsiPath = "$FsBinPath\Fsi.exe"
$FscPath = "$FsBinPath\Fsc.exe"

$MiniCygBin = "D:\Dev\Cygbin"
Set-Alias rlwrap "$MiniCygBin\rlwrap.exe"

#function fsi {rlwrap fsi $args}

Set-Alias l ls
Set-Alias posh powershell

# Show all files
function lla {ls -Force}

function .. { push-location .. }
function ... { push-location ../.. }
function e. {explorer .}

function Edit-Vimrc { gvim $home\.vimrc.local }

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

function code {
  & "C:\Program Files (x86)\Microsoft VS Code\Code.exe" $args
}

if (-not $env:VimRuntime) {
  $env:VimRuntime = "D:\Dev\tools\vim80"
}

function Vim { & "$env:VimRunTime\vim.exe" $args }
function GVim { & "$env:VimRunTime\gvim.exe" $args }


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

function Reload-Profile
{
  . $UserProfile

  echo "Profile is reloaded"
}

function Edit-Profile { gvim $UserProfile }

function Reload-StartupScript
{
  $previousLocation = $pwd
  . $startupScript
  echo "Startup script reloaded"
  cd $previousLocation
}

function Edit-StartupScript { gvim $StartupScript }

# TODO: Move module configuration to a separate file
# Init and config PsReadline
# Should put PsReadline related configs in a separate file
# Should detect if the PS Host is PsReadline-sible

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Set-PSReadlineOption -EditMode Emacs
}

Pop-Location
