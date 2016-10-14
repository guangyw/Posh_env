
function ols {
  if (-not (Test-Path "$env:SrcRoot\ols\ols.bat")) {
    Write-Warning "Not in an OLS enlistment"
    return
  }
  & $env:SrcRoot\ols\ols.bat $args
}

function VsOls {
  $slnPath = "$env:SrcRoot\ols\ols.sln"
  if (-not (Test-Path $slnPath)) {
    Write-Warning "Not in an OLS enlistment"
    return
  }
  devenv $slnPath
}

function VsSvcDef {
  $slnPath = "$env:SrcRoot\osisvcdef\ols\src\ServiceDefinitions\ols\Ols.sln"
  if (-not (Test-Path $slnPath)) {
    Write-Warning "Not in an OLS enlistment"
    return
  }
  devenv $slnPath
}

function BuildED {
  Write-Host "Building SvcDef..." -ForegroundColor Cyan
  Push-Location "$env:SrcRoot\osisvcdef\ols\"
  quickbuild
  Pop-Location

  Write-Host "Running EDGen..." -ForegroundColor Cyan
  Push-Location "$env:SrcRoot\osiedgen\ols\"
  quickbuild
  Pop-Location
}

# Config OSI OBD proxy
Set-ObdDefaultProxyHost OsiSem
