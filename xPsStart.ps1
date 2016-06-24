# PowerShell bootstrap script for OE CoreXt environment

param (
  [string]$EnvFilePath = "D:\dev\config\corext-ols-main.xml"
)

if (Get-Module ZLocation -ListAvailable) {
  # Import Z-Location
  Import-Module ZLocation
  Write-Host -Foreground Yellow "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations."
}

if (Get-Module Posh-Git -ListAvailable) {
  Import-Module Posh-Git

  # Set up a simple prompt, adding the git prompt parts inside git repos
  function global:prompt {
      $realLASTEXITCODE = $LASTEXITCODE

      #Write-Host($pwd.ProviderPath) -nonewline
      Write-Host ">" -NoNewline
      Write-VcsStatus
      Write-Host "`n$pwd" -NoNewline

      $global:LASTEXITCODE = $realLASTEXITCODE

      return "> "
  }

  # Let's VSO style auth
  # Start-SshAgent -Quiet
}

Push-Location $PsScriptRoot

$Workspace = "d:\dev\Workspace"

. ".\Profile.ps1"
. ".\lib\FileSys.ps1"

# It would still be useful to have basic otools commands in CoreXt environment
. ".\lib\SdCommon.ps1"

. ".\OlsDev.ps1"

$UserDepot = "E:\UserDepot\hew"
$env:Path = "$UserDepot\bin;$UserDepot\Scripts;$env:Path"

# Load the environment from xml env definition
.\bin\envutil load $EnvFilePath

# In case otools as a dependencies is removed from OE CoreXT ?
$ExOtools = $env:otools

$SdToolsOptions = @{
    SDEDITOR = "$ExOtools\bin\resolver.exe";
    SDFDIFF = "$ExOtools\bin\sdvdiff.exe -LO";
    SDPDIFF = "$ExOtools\bin\sdvdiff.exe";
    SDPWDIFF = "$ExOtools\bin\sdvdiff.exe";
    SDVCDIFF = "$ExOtools\bin\sdvdiff.exe -LD";
    SDVDIFF = "$ExOtools\bin\sdvdiff.exe"
}

foreach ($kv in $SdToolsOptions.GetEnumerator()) {
  Set-Item -Path "env:$($kv.Key)" -Value $kv.Value
}

$StartupScript = $PsCommandPath

function devosi {
  & "$env:otools\bin\osi\devosi.bat" $args
}

# Directory shortcuts
function src {push-location $env:SrcRoot}

# ------------------------------------------
Push-Location $env:SrcRoot;

if ($env:EnlistmentName) {
  Set-Title "$env:EnlistmentName"
}

Write-Host "CoreXT env $env:EnlistmentName"
