# Execute Visual Studio Unit Tests in commandline
# A wrapper of VSTest.Console.exe

<#
-- options
#>

param (
  [Parameter(Mandatory=$false, Position=0)]
  [string]$TestContainer,

  [Parameter(Mandatory=$false)]
  [string]$WorkingDirectory,

  [Parameter(Mandatory=$false)]
  [Switch]$Forever,

  [Parameter(Mandatory=$false)]
  [Switch]$StopOnFailure = $true
)

$VsTestBin = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"

if (-not $WorkingDirectory) {
  $WorkingDirectory = (Get-Location).Path
}

if (-not (Test-Path $WorkingDirectory)) {
  mkdir $WorkingDirectory
}

if (-not $TestContainer) {
  $containers = ls -Filter "*.UnitTests.dll"

  $fileNames = $containers | Select -Expand Name
  $filePaths = $containers | Select -Expand FullName

  $TestContainer = $filePaths -Join ","
  Write-Warning "Use test containers $fileNames"
}

# Let's drop this for now
#Write-Warning "Working directory: $WorkingDirectory"

$Output = & $VsTestBin /Logger:Trx $TestContainer

# Keep in mind that $Output is an arry of lines
$Output = $Output -join "`n"

Write-Verbose "[VSTest.Console.exe] Console output:"
Write-Verbose $Output

if ($Output -match "Results File: (.+)\n") {
  $TrxPath = $matches[1]
  Write-Verbose "Trx FilePath: $TrxPath"
  $Result = Get-VSTrxResults $TrxPath
  return $Result
} else {
  Write-Error "Trx file not found"
  return $Output
}
