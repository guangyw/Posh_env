# Read VS TRX file and return the result

param(
  [Parameter(Mandatory=$true)]
  [string]$FilePath
)

$doc = [xml](cat $FilePath)

$doc.TestRun.Results.UnitTestResult `
| Select @{Name="Name"; Expression={$_.TestName}}, `
         @{Name="Passed"; Expression={$_.Outcome -eq "Passed"}}, `
         @{Name="Duration"; Expression={[Timespan]::Parse($_.Duration)}}, `
         @{Name="Error"; Expression={
           if ($_.Outcome -ne "Passed") {
             $message = $_.Output.ErrorInfo.Message
             $stackInfo = $_.Output.ErrorInfo.StackTrace
             return "Message: $message`nStackTrace: $stackInfo"
           } else { "" }
         }}
