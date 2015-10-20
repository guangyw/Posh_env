# Startup script for PsEnlistment

Push-Location $PsScriptRoot
Import-CliXml e:\Office-EnvVar.xml | % {set-item -path env:$($_.Key) -value $_.Value };

. ".\Profile.ps1"

$UserDepot = "E:\UserDepot\hew"
$env:Path = "$UserDepot\bin;$UserDepot\Scripts;$env:Path"

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

function enter-vdev {
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
$SdClientName = "hew-dev"
Set-Title "PS: $SdClientName"

newline "Welcome to PsEnlistment ($SdClientName)"
omotd -tip
newline

Push-Location $env:SrcRoot;
