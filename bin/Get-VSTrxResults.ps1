# Read VS TRX file and return the result

param(
  [Parameter(Mandatory=$true)]
  [string]$FilePath
)

$doc = [xml](cat $FilePath)

$doc.TestRun.Results.UnitTestResult `
| Select @{Name="TestName"; Expression={$_.TestName}}, `
         @{Name="Passed"; Expression={$_.Outcome -eq "Passed"}}, `
         @{Name="Duration"; Expression={[Timespan]::Parse($_.Duration)}}
