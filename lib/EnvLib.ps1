. $PsScriptRoot\..\config\ManageConfig.ps1

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

function Add-Path {
  param(
    [Parameter(mandatory=$true)]
    [string]$path
  )
  if (-not (Test-Path $path -PathType Container)) {
    Write-Error "Path does not exist $path"
    return
  }

  $fullPath = (Get-Item $path).FullName

  Write-Verbose "Add $fullPath to local path"
  $env:Path = "$env:Path;$fullPath"
}
