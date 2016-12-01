
$ConfigFilePath = Join-Path $PsScriptRoot "config.json"

function Get-PsEnvConfig {
  ConvertFrom-Json $ConfigFilePath
}
