# PowerShell bootstrap script for OE CoreXt environment

param (
  [string]$EnvFilePath = "D:\dev\config\corext-ols-main.xml",

  [string]$CmdEnvFilePath
)

$StartupScriptLoadTime = [DateTime]::UtcNow
$StartupScript = $PsCommandPath

Push-Location $PsScriptRoot

. ".\config\PreConfig.ps1"
. ".\Profile.ps1"
. ".\lib\FileSys.ps1"
. ".\lib\Common.ps1"

# It would still be useful to have basic otools commands in CoreXt environment
. ".\lib\SdCommon.ps1"

. ".\OlsDev.ps1"

# Load the environment from xml env definition, or from cmd env loader
if ($CmdEnvFilePath) {
  .\bin\Load-CmdEnv.ps1 $CmdEnvFilePath
} elseif ($EnvFilePath) {
  .\bin\EnvUtil.ps1 Load $EnvFilePath
}

# In case otools as a dependencies is removed from OE CoreXT
$ExOtools = $env:otools

if (Test-Path $ExOtools) {
  $SdToolsOptions = @{
      SDEDITOR = "$ExOtools\bin\resolver.exe";
      SDFDIFF = "$ExOtools\bin\sdvdiff.exe -LO";
      SDPDIFF = "$ExOtools\bin\sdvdiff.exe";
      SDPWDIFF = "$ExOtools\bin\sdvdiff.exe";
      SDVCDIFF = "$ExOtools\bin\sdvdiff.exe -LD";
      SDVDIFF = "$ExOtools\bin\sdvdiff.exe"
  }

  $Env:Path = "$Env:Path;$ExOtools\bin\"
}

foreach ($kv in $SdToolsOptions.GetEnumerator()) {
  Set-Item -Path "env:$($kv.Key)" -Value $kv.Value
}

function devosi {
  & "$env:otools\bin\osi\devosi.bat" $args
}

# Directory shortcuts
function src { push-location $env:SrcRoot }

# Build related
function qb {
  $startTime = [DateTime]::Now
  quickbuild $args
  $endTime = [DateTime]::Now
  $duration = $endTime - $startTime

  Write-Host "Build starts: $startTime"
  Write-Host "Build ends: $endTime"
  Write-Host "Duration: $duration"
}

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
} elseif ($env:ConEmuTask) {
  $env:EnlistmentName = $env:ConEmuTask.Trim('{}')
}

Write-Logo
Write-Host ""
Write-Host "Welcome to Posh-Env for $env:EnlistmentName (CoreXT)`n"
