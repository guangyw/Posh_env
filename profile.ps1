# PowerShell Profile for Heng Wang

# This Profile will only affect the Windows PowerShell
# Excluding PowerShell Implementation by Others
# Should be fine to put everything here

# Init and config PsReadline
# Should put PsReadline related configs in a separate file
# Should detect if the PS Host is PsReadline-sible

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Set-PSReadlineOption -EditMode Emacs
}

$UserProfile = "$PsScriptRoot\profile.ps1"
$Workspace = "d:\dev\workspace"
if (-not $StartupScript)
{
  $StartupScript = $UserProfile
}

Push-Location $PsScriptRoot

. ".\Utility.ps1"

$FsHome = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0"
$FsBinPath = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0\Framework\v4.0"
$env:Path += ";$FsBinPath"
$env:Path = "C:\Cygwin64\Bin;" + $env:Path
$env:Path += ";$PsScriptRoot\bin"
$env:Path += ";$PsScriptRoot\obin"

$AtomPath = "C:\Users\hew\AppData\Local\atom\bin"
if (Test-Path $AtomPath) {
    $env:Path += ";$AtomPath"
}

$env:PathExt += ";.Py"
$env:PathExt += ";.Fsx"
$env:PathExt += ";.FsScript"

$FsiPath = "$FsBinPath\Fsi.exe"
$FscPath = "$FsBinPath\Fsc.exe"

$CygwinBinPath = "C:\cygwin64\bin\"
Set-Alias rlwrap "$CygwinBinPath\rlwrap.exe"

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
  Get-Command $args | Select Path
}

function Get-LastDown
{
    # user profile is $env:UserProfile
    $downloadFolder = Join-Path $env:UserProfile "Downloads"
    $targetFile = ls $downloadFolder -File `
    | Sort-Object CreationTime -Descending `
    | Select-Object -First 1 `

    $currentPath = Get-Location
    Write-Host ">>> Move $($targetFile.Name) to`n>>> $currentPath"
    Move-Item -Path $targetFile.FullName -Destination $currentPath
    Write-Host ">>> Done"
}

function code {
  & "C:\Program Files (x86)\Microsoft VS Code\Code.exe" $args
}

$VimRuntime = "C:\Program Files (x86)\Vim\vim74"
function GVim
{
  param(
  [Parameter(Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true
  )]
  [Alias("FilePath", "FullName")]
  [string[]]$Path
  )

  Begin{
    $PathList = [System.Collections.ArrayList]@();
  }

  Process{
    echo "Arg: $Path"
    $Path |% {$PathList.Add($_)}
  }

  End{
    echo "PathList is: $PathList"
    & "$VimRunTime\gvim.exe" -p $PathList
  }
}


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

function copypwd {
  $pwd.Path | clip
}

function copypath {
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

Pop-Location


