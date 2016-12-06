. $PsScriptRoot\Common.ps1

$CacheLocation = Join-Path $PsEnvRoot ".data\EnvironmentCache\"

if (-not (Test-Path $CacheLocation)) {
  mkdir $CacheLocation
}

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

function Get-CurrentEnvHashByIdFiles {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $config = Get-PsEnvironmentConfig $EnvironmentName

  $monitoredFiles = $config.EnvironmentTypeConfig.CacheIdFiles

  $contents = $monitoredFiles `
  |% { Join-Path $config.Root $_ } `
  |? { Test-Path $_ <# Silently ignore non-existance #> } `
  | Sort `
  |% { Get-Content $_ }

  $content = $contents -join ''

  # $content can be empty because we silently ignored some files
  if (-not $content) {
    # Return random hash
    return [Guid]::NewGuid().ToString()
  }

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

  # TODO: metadata for the hash
  # LastWriteTime / Generate time
  if (Test-Path $envHashPath) {
    cat $envHashPath
  } else {
    ""
  }
}

function Test-CacheByIdFiles {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $CurrentEnvHash = Get-CurrentEnvHashByIdFiles $EnvironmentName
  $CachedEnvHash = Get-CachedEnvHash $EnvironmentName

  $CurrentEnvHash -eq $CachedEnvHash
}

function Save-Cache {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $currentEnvHash = Get-CurrentEnvHashByIdFiles $EnvironmentName
  $envHashPath = Get-EnvHashPath $EnvironmentName
  $currentEnvHash | Out-File $envHashPath -Encoding UTF8 -Force -NoNewline

  $envCachePath = Get-EnvCachePath $EnvironmentName
  EnvUtil Save $envCachePath
}

function Init-Env {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $config = Get-PsEnvironmentConfig $EnvironmentName

  Write-Verbose "Env cache miss"
  if (Test-Path $config.InitScript) {
    Write-Verbose "Load-CmdEvn from $($config.InitScript)"
    Load-CmdEnv $config.InitScript
  } elseif ($config.InitScript -match "^{.*}$") {
    Write-Verbose "Init env using script block $($config.InitScript)"
    # TODO: how to invoke this script block?
  } else {
    Write-Error "Cannot init from $config.InitScript"
  }
}

function Init-EnvWithCache {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $config = Get-PsEnvironmentConfig $EnvironmentName
  $cachePolicy = $config.EnvironmentTypeConfig.CachePolicy

  if ($cachePolicy -eq "None") {

    Init-Env $EnvironmentName

  } elseif ($cachePolicy -eq "ByIdFiles") {

    if (Test-CacheByIdFiles $EnvironmentName) {
      Write-Verbose "Env cache hit -> cache timestamp [TODO]"
      $envCachePath = Get-EnvCachePath $EnvironmentName
      EnvUtil Load $envCachePath
      return
    }

    Init-Env $EnvironmentName

    Save-Cache $EnvironmentName

  } else {

    Write-Warning "Unknown CachePolicy $cachePolicy"

    Load-CmdEnv $config.InitScript

  }
}
