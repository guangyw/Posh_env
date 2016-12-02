$ConfigFilePath = Join-Path $PsScriptRoot "config.json"

function Get-PsEnvFullConfig {
  # Configurations from any other places?
  if (Test-Path Variable:Global:_PsEnv_FullConfig) {
    return $global:_PsEnv_FullConfig
  }

  $global:_PsEnv_FullConfig = cat $ConfigFilePath | ConvertFrom-Json
  return $global:_PsEnv_FullConfig
}

function Get-PsEnvironments {
  Get-PsEnvFullConfig `
  | Select -Expand Environments `
  |% { [PsCustomObject] @{
        Name = $_.Name
        Type = $_.Type
        Root = $_.Root
        InitScript = $_.InitScript
        SourceControlType = $_.SourceControl.Type
      }
  }
}

function Get-PsEnvironmentConfig {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentName
  )

  $fullConfig = Get-PsEnvFullConfig
  $environmentConfig = $fullConfig.Environments `
  |? {$_.Name -eq $EnvironmentName} `
  | Select -First 1

  if (-not $environmentConfig) {
    Write-Error "Environment $EnvironmentName doesn't exist" -Category InvalidArgument
    return
  }

  $configItems = $environmentConfig.Configurations
  $environmentConfig.Configurations = $fullConfig.Configurations
  $configItems.PsObject.Properties `
  |% {
     Add-Member -InputObject $environmentConfig.Configurations `
                -MemberType NoteProperty `
                -Name $_.Name `
                -Value $_.Value `
                -Force
  }

  Add-Member -InputObject $environmentConfig `
             -MemberType NoteProperty `
             -Name "EnvironmentTypeConfig" `
             -Value (Get-PsEnvironmentTypeConfig $environmentConfig.Type) `
             -Force

  return $environmentConfig
}

function Get-PsEnvironmentTypeConfig {
  param (
    [Parameter(Mandatory=$true)]
    [string]$EnvironmentTypeName
  )

  $fullConfig = Get-PsEnvFullConfig
  $envTypeConfig = $fullConfig.EnvironmentTypes `
  |? {$_.Name -eq $EnvironmentTypeName} `
  | Select -First 1

  if (-not $envTypeConfig) {
    Write-Error "Environment type $EnvironmentTypeName doesn't exist" -Category InvalidArgument
    return
  }

  return $envTypeConfig
}

function Load-GlobalConfiguration {
  $fullConfig = Get-PsEnvFullConfig

  $fullConfig.Configurations.EnvironmentVariableOverrides.PsObject.Properties `
  |% { Set-Item -Path "Env:$($_.name)" -Value $_.value }

  $editor = $fullConfig.Configurations.Editor
  # TODO: how about Add-EnvVar
  Set-Item -Path "Env:PsEnv_Editor" -Value $editor
}
