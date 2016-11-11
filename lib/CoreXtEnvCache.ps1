Push-Location

. .\Common.ps1

$CacheLocation = Join-Path $PsEnvRoot ".data\CoreXtEnvCache\"

if (-not (Test-Path $CacheLocation)) {
  mkdir $CacheLocation
}

$MonitoredFiles = @(
  # Path relative to the repo root
  "private\otools\ovr\tenantols.meta"
  "private\otools\ovr\tenantols.override"
  ".corext\corext.config"
  "build\corext\corext.config"
  "private/warehouse/tenantols/cross/cross/x-none/NugetImportPackage.manifest"
  "build/config/office_cloudbuild_config.json"
)

function Get-CurrentCoreXtEnvHash {
}

function Test-Cache {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvHash
  )
}

function Save-Cache {
}

function Get-Cache {
}

function Init-EnvWithCache {
  param (
    [Parameter(Mandatory=$true)]
    [ScriptBlock]$EnvInitCallback

  )
}

Pop-Location
