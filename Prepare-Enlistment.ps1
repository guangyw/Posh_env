
$EnlistmentRoot = Split-Path -Path $env:SrcRoot -Parent
echo $EnlistmentRoot

$EnvVarFilePath = "$EnlistmentRoot\EnvVar.xml"
echo $EnvVarFilePath

$PsStartupScriptPath = "$EnlistmentRoot\oPsStart.ps1"

echo ''
echo "Save environment variables to $EnvVarFilePath"

ls env: | Export-CliXml -Path $EnvVarFilePath

# Further load the saved environment variables using:

echo @"
# Startup script for Enlistment %EnlistmentTitle% (%EnlistmentRoot%)
Import-CliXml $EnvVarFilePath | % {set-item -path env:`$(`$_.Key) -value `$_.Value };
Push-Location $env:SrcRoot;
"@ | Out-File $PsStartupScriptPath

cat $PsStartupScriptPath

