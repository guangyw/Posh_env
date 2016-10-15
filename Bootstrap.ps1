

foreach ($module in @("PSReadline", "ZLocation", "Posh-Git")) {
  if (-not (Get-Module ZLocation -ListAvailable)) {
    Write-Host "Installing $module..." -Foreground Green
    Install-Module ZLocation
  } else {
    Write-Host "$module is found" -Foreground Green
  }
}
