Push-Location $PSScriptRoot

. .\Common.ps1

$CacheLocation = Join-Path $PsEnvRoot ".data\EnvironmentCache\"

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

function Get-EnvHashPath {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  Join-Path $CacheLocation "Environment.$EnvironmentName.hash"
}

function Get-EnvCachePath {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  Join-Path $CacheLocation "Environment.$EnvironmentName.xml"
}

function Get-CurrentEnvHash {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $config = Get-PsEnvironmentConfig $EnvironmentName

  $contents = $MonitoredFiles `
  |% { Join-Path $config.Root $_ } `
  |? { Test-Path $_ } `
  | Sort `
  |% { Get-Content $_ }

  $content = $contents -join ''

  $Hash = $content.GetHashCode()
  Write-Host "[Debug] Current Env Hash: $Hash" -ForegroundColor Cyan

  return $Hash
}

function Get-CachedEnvHash {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $envHashPath = Get-EnvHashPath $EnvironmentName

  if (Test-Path $envHashPath) {
    cat $envHashPath
  } else {
    ""
  }
}

function Test-Cache {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $CurrentEnvHash = Get-CurrentEnvHash $EnvironmentName
  $CachedEnvHash = Get-CachedEnvHash $EnvironmentName

  $CurrentEnvHash -eq $CachedEnvHash
}

function Save-Cache {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $currentEnvHash = Get-CurrentEnvHash $EnvironmentName
  $envHashPath = Get-EnvHashPath $EnvironmentName
  $currentEnvHash | Out-File $envHashPath -Encoding UTF8 -Force -NoNewline

  $envCachePath = Get-EnvCachePath $EnvironmentName
  EnvUtil Save $envCachePath
}

function Init-EnvWithCache {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  if (Test-Cache $EnvironmentName) {
    $envCachePath = Get-EnvCachePath $EnvironmentName
    EnvUtil Load $envCachePath
    return
  }

  Write-Host "Env cache miss, init from $($config.StartupScript)"
  $config = Get-PsEnvironmentConfig $EnvironmentName
  Load-CmdEnv $config.StartupScript

  Save-Cache $EnvironmentName
}

Pop-Location
