. $PsScriptRoot\..\config\ManageConfig.ps1

function Test-PsEnv {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $env = Get-PsEnvironments `
  |? {$_.Name -eq $EnvironmentName}

  [bool]$env
}

function Init-PsEnv {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $config = Get-PsEnvironmentConfig $EnvironmentName

  $global:_PsEnv_EnvConfig = $config
  $global:_PsEnv_Name = $config.Name
  $global:_PsEnv_Type = $config.Type
  $global:_PsEnv_Root = $config.Root
  $global:_PsEnv_InitScript = $config.InitScript

  $global:_PsEnv_Workspace = $config.Configurations.Workspace
}

function Switch-Environment {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  if (Test-PsEnv $EnvironmentName) {
    . $PsScriptRoot\..\xPsStart.ps1 -EnvironmentName $EnvironmentName
  } else {
    Write-Warning "Environment ``$EnvironmentName`` is not defined"
  }
}

function Add-Path {
  param(
    [Parameter(Mandatory=$true)]
    [string]$path,

    [Parameter(Mandatory=$false)]
    [switch]$End
  )
  if (-not (Test-Path $path -PathType Container)) {
    Write-Error "Path does not exist $path"
    return
  }

  $fullPath = (Get-Item $path).FullName

  Write-Verbose "Add $fullPath to local path"
  if ($End) {
    $env:Path = "$env:Path;$fullPath"
  } else {
    $env:Path = "$fullPath;$env:Path"
  }
}
