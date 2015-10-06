# PowerShell Profile for Heng Wang

# This Profile will only affect the Windows PowerShell
# Excluding PowerShell Implementation by Others
# Should be fine to put everything here

# Init and config PsReadline
# Should put PsReadline related configs in a separate file
# Should detect if the PS Host is PsReadline-sible

Import-Module PSReadLine
Set-PSReadlineOption -EditMode Emacs

Push-Location $PsScriptRoot

. .\Utility.ps1

$FsBinPath = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0\Framework\v4.0"
$env:Path += ";$FsBinPath"
$env:Path = "C:\Cygwin64\Bin;" + $env:Path
$env:Path += ";$PsScriptRoot\bin"
$env:Path += ";$PsScriptRoot\obin"

$env:PathExt += ";.Py"
$env:PathExt += ";.Fsx"
$env:PathExt += ";.FsScript"

$FsiPath = "$FsBinPath\Fsi.exe"
$FscPath = "$FsBinPath\Fsc.exe"

$CygwinBinPath = "C:\cygwin64\bin\"
Set-Alias rlwrap "$CygwinBinPath\rlwrap.exe"

$UserProfile = "$PsScriptRoot\profile.ps1"
$Workspace = "d:\dev\workspace"

function fsi {rlwrap fsi $args}

Set-Alias l ls
Set-Alias vi vim

# Show all files
function lla {ls -Force}

function .. { push-location .. }
function ... { push-location ../.. }
function Edit-Profile { gvim $UserProfile }
function Edit-Vimrc { gvim $home\.vimrc.local }

function e. {explorer .}

function which
{
  Get-Command $args | Select Path
}

function Reload-Profile
{
  . $UserProfile
  "Profile is reloaded"
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


Pop-Location
Push-Location $Workspace

