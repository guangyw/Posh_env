function Get-SdConfig {
  $path = $pwd.Path
  while ($true) {
    if (-not $path) {
      Write-Warning "Not under SD root"
      return
    }

    $sdiniPath = Join-Path $path "sd.ini"
    if (Test-Path $sdiniPath) {
      break
    } else {
      $path = Split-Path $path
    }
  }

  $config = @{}
  Get-Content $sdiniPath `
  |% {$k, $v = $_ -split "="; @{Key=$k; Value=$v}} `
  |% {$config[$_.Key] = $_.Value}

  return [PSCustomObject] $config
}
