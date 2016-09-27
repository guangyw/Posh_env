# Execute Visual Studio Unit Tests in commandline
# A wrapper of VSTest.Console.exe

$VsTestBin = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"

param(
  [Parameter(Mandatory=$true)]
  [string]$TestContainer,

  [Parameter(Mandatory=$false)]
  [string]$WorkingDirectory,

  [Parameter(Mandatory=$false)]
  [Switch]$Forever,

  [Parameter(Mandatory=$false)]
  [Switch]$StopOnFailure = $true
)

$ExecutionResults = @{}
