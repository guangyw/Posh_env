
function ols {
  if (-not (Test-Path "$env:SrcRoot\ols\ols.bat")) {
    Write-Warning "Not in an OLS enlistment"
    return
  }
  & $env:SrcRoot\ols\ols.bat $args
}

function vsols {
  $slnPath = "$env:SrcRoot\ols\ols.sln"
  if (-not (Test-Path $slnPath)) {
    Write-Warning "Not in an OLS enlistment"
    return
  }
  devenv $slnPath
}
