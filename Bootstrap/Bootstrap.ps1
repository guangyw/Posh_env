
@("PSReadline", "ZLocation", "Posh-Git") `
|? { -not (Get-Module $_ -ListAvailable) } `
|% {
  Write-Host "Installing $_ ..." -Foreground Green
  Install-Module $_
}
