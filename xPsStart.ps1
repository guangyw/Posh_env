# PowerShell bootstrap script for OE CoreXt environment

param (
  [Parameter(Mandatory=$true)]
  [string]$EnvironmentName
)

# This will be effective in the entire PowerShell session
Set-StrictMode -Version latest

$global:_PsEnv_StartupTime = [DateTime]::UtcNow
$global:_PsEnv_StartupCommand = $PsCommandPath

Push-Location $PsScriptRoot

# Regular profile that has nothing to do with PsEnv
. ".\Profile.ps1"

# PsEnv imports
. ".\lib\Common.ps1"
. ".\config\ManageConfig.ps1"
. ".\lib\CoreXtEnvCache.ps1"
. ".\lib\EnvLib.ps1"
. ".\lib\Utility.ps1"
. ".\lib\FileSys.ps1"

# Office related files -- move to elsewhere
. ".\lib\OfficeUtility.ps1"

Init-PsEnv $EnvironmentName

. ".\Config\LoadModules.ps1"

$config = Get-PsEnvironmentConfig $EnvironmentName

Load-GlobalConfiguration

if ($EnvironmentName) {
  Init-EnvWithCache $EnvironmentName
} else {
  Write-Error "Expect EnvironmentName or CmdEnvFilePath"
}

# It would still be useful to have basic otools commands in CoreXt environment
. ".\lib\SdCommon.ps1"

# OSI specific tools and configs
Add-Path .\OSI\

# OLS specific tools and configs
. ".\OLS\OlsDevConfig.ps1"
Add-Path .\OLS\

# In case otools as a dependencies is removed from OE CoreXT
$ExOtools = $env:otools
if ($ExOtools -and (Test-Path $ExOtools)) {
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

  Add-Path $ExOtools\bin\
}

function devosi {
  & "$env:otools\bin\osi\devosi.bat" $args
}

# Directory shortcuts
function src { Push-Location $env:SrcRoot }

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

  ws = $global:_PsEnv_Workspace;
  "psenv" = $PsScriptRoot;

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

if ($config.Configurations.SourceHomeDir) {
  Push-Location $config.Configurations.SourceHomeDir;
} else {
  Push-Location $config.Root
}

# TODO: Title is currently being overridden by posh-git
if ($env:EnlistmentName) {
  Set-Title "$env:EnlistmentName"
} elseif ($env:ConEmuTask) {
  $env:EnlistmentName = $env:ConEmuTask.Trim('{}')
}

Write-Logo
Write-Host ""
Write-Host "Welcome to PsEnv for $($config.Name) ($($config.Type))"
Write-Host ""
