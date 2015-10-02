$EnlistmentRoot = $env:EnlistmentRoot
$ohwStartEnlistment = Join-Path $EnlistmentRoot "oStart.bat"

Push-Location $PSScriptRoot

. .\dailyTaskUtils.ps1

ls env: | Foreach-Object {Write-Log "$($_.Key): $($_.Value)"; Write-Output $_}
ls env: | Export-CliXml "e:\office-envvar.xml"

"Current user is: " + [Environment]::UserName | Foreach-Object {Write-Log $_; Write-Output $_}
"Is Elevated: " + (Test-Elevated) | Foreach-Object {Write-Log $_; Write-Output $_}


# ------------------------------------------------------

# TODO: sdp pack/apply existing changelist
# TODO: How about redirect all stdout/stderr for subsequent processes.

$startTime = Get-Date
Write-Log "---------- Start Daily Scheduled Task -----------"

latest | Foreach-Object {Write-Log $_; Write-Output $_}

<#

Write-Log "---------- Start oSync -----------"
which osync | Foreach-Object {Write-Log $_; Write-Output $_}
osync | Foreach-Object {Write-Log $_; Write-Output $_}

Write-Log "---------- Start oHome (with sync) -----------"
ohome clean sync build debug noocheck | Foreach-Object {Write-Log $_; Write-Output $_}

#>

#runbb | Foreach-Object {Write-Log $_; Write-Output $_}

#devosi deploydev debug OmexCoSubRetailer-DevFabric | Write-Log | Write-Output

#ohome help | Foreach-Object {Write-Log $_; Write-Output $_}

Write-Log "Daily Scheduled Task Done"
Write-Log "Total time: $((Get-Date) - $startTime | Format-TimeDuration)"

Pop-Location

<#

 $envvars | % {set-item -path env:$($_.Key) -value $_.Value }

 #>