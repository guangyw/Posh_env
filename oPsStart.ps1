# Startup script for PsEnlistment

param (
  [string]$EnvFilePath = "e:\Office-Env.xml"
)

# Import Z-Location
Import-Module ZLocation
Write-Host -Foreground Green "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations.`n"

Push-Location $PsScriptRoot

<#
TODO: the order / dependencies are getting harder to figure out
 #>

$Workspace = "e:\Workspace"
$env:JAVA_HOME = "E:\App\jdk1.8.0_65"

. ".\Profile.ps1"
. ".\lib\FileSys.ps1"

$UserDepot = "E:\UserDepot\hew"
$env:Path = "$UserDepot\bin;$UserDepot\Scripts;$env:Path"

# Load the environment from xml env definition
.\bin\envutil load $EnvFilePath

if ($env:LIB -eq "--must-override-in-makefile--") {
  # I think this is a bad decision, developers are not monkeys
  $env:LIB = ''
}

$StartupScript = $PsCommandPath

function newline
{
  if ($args) {
    echo "$args`n"
  } else {
    echo ""
  }
}

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
function vstelemetry {devenv "$env:SrcRoot\omexservices\telemetry\OmexTelemetry.sln"}
function vsreconciler {devenv "$env:SrcRoot\omexservices\reconciler.sln"}

function Enter-Vdev {
  Enter-PSSession -ComputerName hew-vdev -Authentication CredSSP -Credential (Get-Credential)
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

# Directory shortcuts
function src {push-location $env:SrcRoot}

function Build-PatchDev {
  ohome build debug patchdev*
}


# ------------------------------------------
Push-Location $env:SrcRoot;

$sdinfo = sdinfo
$SdClientName = $sdinfo."Client name"
Set-Title "PS: $SdClientName"
# TODO: Consider output synced checkpoint number

newline "Welcome to PsEnlistment ($SdClientName)"
omotd -tip
newline
