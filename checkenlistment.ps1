# Bootstrap the enlistment environment by setting up environment variables

$envvars = Import-CliXml "e:\Office-EnvVar.xml";
$envvars | % {Set-Item -path env:$($_.Key) -value $_.Value }

$SDPORT="OFFDEPOT1:4000"
$SDFORMEDITOR="sdforms.exe"
$SDCLIENT="hew-dev"
$SDROOT="E:\Office"
$SDLOCATION="Ireland"

$env:SDPORT="OFFDEPOT1:4000"
$env:SDFORMEDITOR="sdforms.exe"
$env:SDCLIENT="hew-dev"
$env:SDROOT="E:\Office"
$env:SDLOCATION="Ireland"

ls env: | echo

. E:\UserDepot\hew\bin\dailyTaskUtils.ps1

sd opened | Foreach-Object {Write-Log $_; Write-Output $_}
