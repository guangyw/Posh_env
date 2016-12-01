$ConfigFilePath = Join-Path $PsScriptRoot "config.json"

function Get-PsEnvFullConfig {
  # Configurations from any other places?
  cat $ConfigFilePath | ConvertFrom-Json
}

function Get-PsEnvironments {
  Get-PsEnvFullConfig `
  | Select -Expand Environments `
  |% { [PsCustomObject] @{
        Name = $_.Name
        Type = $_.Type
        Root = $_.Root
        SourceControlType = $_.SourceControl.Type
      }
  }
}

function Get-PsEnvironmentConfig {
  param ( [string]$EnvironmentName )

  $fullConfig = Get-PsEnvFullConfig
  $EnvironmentConfig = $fullConfig.Environments `
  |? {$_.Name -eq $EnvironmentName} `
  | Select -First 1

  if (-not $EnvironmentConfig) {
    Write-Error "Environment $EnvironmentName doesn't exist" -Category InvalidArgument
    return
  }

  $configItems = $EnvironmentConfig.Configurations
  $EnvironmentConfig.Configurations = $fullConfig.Configurations
  $configItems.PsObject.Properties `
  |% {
     Add-Member -InputObject $EnvironmentConfig.Configurations `
                -MemberType NoteProperty `
                -Name $_.Name `
                -Value $_.Value `
                -Force
  }

  return $EnvironmentConfig
}

function Load-GlobalConfiguration {
  $fullConfig = Get-PsEnvFullConfig

  $fullConfig.Configurations.EnvironmentVariableOverrides.PsObject.Properties `
  |% { Set-Item -Path "Env:$($_.name)" -Value $_.value }

  $editor = $fullConfig.Configurations.Editor
  # TODO: how about Add-EnvVar
  Set-Item -Path "Env:PsEnv_Editor" -Value $editor
}
