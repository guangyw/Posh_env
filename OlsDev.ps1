
function ols {
  $ols = "$env:SrcRoot\ols\ols.bat"
  & "$ols $_"
}

function vsols {
  $slnPath = "$env:SrcRoot\ols\ols.sln"
  if (-not (Test-Path $slnPath)) {
    Write-Warning "Not in an OLS enlistment"
    return
  }
  devenv $slnPath
}
