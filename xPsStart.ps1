# PowerShell bootstrap script for OE CoreXt environment

param (
  [string]$EnvFilePath = "D:\dev\config\corext-ols-main.xml"
)

if (Get-Module ZLocation -ListAvailable) {
  # Import Z-Location
  Import-Module ZLocation
  Write-Host -Foreground Yellow "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations."
}

# TODO: consider eliminate the requirement for this
# (Write something better, or with better control)
if (Get-Module Posh-Git -ListAvailable) {
  Import-Module Posh-Git

  # Set up a simple prompt, adding the git prompt parts inside git repos
  function global:prompt {
      $realLASTEXITCODE = $LASTEXITCODE

      # TODO: show provider
      #Write-Host($pwd.ProviderPath) -nonewline

      # TODO: Do not print this if not under git repo
      Write-Host ">" -NoNewline
      Write-VcsStatus
      Write-Host "`nPS $pwd" -NoNewline

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
. ".\lib\Common.ps1"

# It would still be useful to have basic otools commands in CoreXt environment
. ".\lib\SdCommon.ps1"

. ".\OlsDev.ps1"

$UserDepot = "D:\UserDepot\hew"
$env:Path = "$UserDepot\bin;$UserDepot\Scripts;$env:Path"

# Load the environment from xml env definition
.\bin\envutil.ps1 load $EnvFilePath

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
function src { push-location $env:SrcRoot }

# Build related
function qb { quickbuild $_ }

# JumpDict should be an env specific setting
$jumpDict = @{
  src = "$env:SrcRoot";
  svcdef = "$env:SrcRoot\osisvcdef\ols\src\ServiceDefinitions\ols";
  ols = "$env:SrcRoot\ols";
  nugetcache = "D:\NugetCache";
  target = "$env:TargetRoot";
  olstarget = "$env:TargetRoot\x64\debug\ols\x-none";

  ed = "$env:TargetRoot\x64\debug\osiedgen_ols\x-none\EnvironmentDescriptionFiles";

  build = "$env:SrcRoot\..\out\x64\debug";
  olsbuild = "$env:SrcRoot\..\out\x64\debug\ols";

  ws = $workspace;
  "posh-env" = $PsScriptRoot;

  downloads = "$env:home\Downloads";
}

function c ($label) {
  if ($jumpDict.ContainsKey($label)) {
    $dest = $jumpDict[$label]
    Push-Location $dest
  } else {
    Write-Warning "Unknown label $label"
  }
}

function cdi {
  # cd into
  if ($args[0]) {
    Push-Location $args[0]
  }

  $dirs = ls -Directory "."
  if ($dirs.Count -eq 1) {
    Push-Location $dirs[0]
    cdi
  }
}

# TODO: can you access the location jumping stack somewhere?

# ------------------------------------------
Push-Location $env:SrcRoot;

if ($env:EnlistmentName) {
  Set-Title "$env:EnlistmentName"
}

Write-Logo

Write-Host ""

Write-Host "Welcome to PsEnv for $env:EnlistmentName (CoreXT)`n"
