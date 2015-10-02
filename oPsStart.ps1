# Bootstrap script for PsEnlistment

# Should be set in $profile so that it applies to native client as well
#Import-Module PsReadline
#Set-PSReadlineOption -EditMode Emacs

Import-CliXml e:\Office-EnvVar.xml | % {set-item -path env:$($_.Key) -value $_.Value };
Push-Location $env:SrcRoot;

$env:Path += ";E:\UserDepot\hew\Scripts"

$FSharpHome = "C:\Program Files (x86)\Microsoft SDKs\F#\4.0\Framework\v4.0"
$env:Path += ";$FSharpHome"


$startupScript = $PsCommandPath

function Reload-StartupScript
{
  $previousLocation = $pwd
  . $startupScript
  echo "Startup script reloaded"
  cd $previousLocation
}

$Host.UI.RawUI.WindowTitle = "PS: hew-dev"

Set-Item -Path function:shabi -Value "echo shabi" | Out-Null

function newline
{
  if ($args) {
    echo "$args`n"
  } else {
    echo ""
  }
}

function .. {cd ..}
function ... {cd ..\..}
function e. {explorer .}
function osubmit
{
  if ($args) {
    & "$env:otools\bin\osubmit.bat" $args
  } else {
    & "$env:otools\bin\osubmit.bat" -tfs
  }
}

function vsomex {devenv "$env:SrcRoot\omexservices\omexservices.sln"}
function vsretailer {devenv "$env:SrcRoot\omexservices\omexretailer.sln"}
function vsshared {devenv "$env:SrcRoot\omexshared\omexshared.sln"}
function vstest {devenv "$env:SrcRoot\omexservices\omexservicestest.sln"}
function vsrec {devenv "$env:SrcRoot\omexservices\reconciler.sln"}

function enter-vdev {
  Enter-PSSession -ComputerName hew-vdev -Authentication CredSSP -Credential (Get-Credential)
}

function Test-Elevated {
  $adminRole = [Security.Principal.WindowsBuiltInRole]"Administrator";
  return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($adminRole)
}

function Run-UT {
  Push-Location E:\office\dev\omexservices\services\diagnostics.unittests
  ut $args -t MS.Internal.Motif.Office.Web.OfficeMarketplace.Diagnostics.Services.Reconciler.ComponentTests.WrongPuidFixAcceptanceTests
  Pop-Location
}

function git {
  & "C:\Program Files (x86)\Git\bin\git.exe" $args
}

function hexpuid {
  $hex = "{0:X}" -f [UInt64]$args[0]
  Write-Output "Hex Puid: $hex"
  $hex | clip
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

# Directory shortcuts
function src {push-location $env:SrcRoot}

function Build-PatchDev {
  ohome build debug patchdev*
}

function vscode {
  C:\Users\hew\AppData\Local\Code\bin\code.cmd $args
}

function copypwd {
  $pwd.Path | clip
}

Set-Alias l ls
Set-Alias posh powershell

# ------------------------------------------

newline "Welcome to PsEnlistment (hew-dev)"
omotd -tip
newline

