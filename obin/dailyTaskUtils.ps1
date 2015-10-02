$ohomeDailyDir = Join-Path $env:LOCALAPPDATA "ohomedaily"

if (-not (Test-Path $ohomeDailyDir))
{
    New-Item -Path $ohomeDailyDir -ItemType Directory
}

$today = Get-Date -Format "yyyy-MM-dd"
$LogFilePath = Join-Path $ohomeDailyDir "Scheduled-$today.log"


function Write-Log
{
    Param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
    [string]$content
    )
    if (!$content)
    {
        Write-Warning "Write-Log got an empty logging message"
        return
    }

    if (!$content.Contains("`n"))
    {
        $content = "[$(Get-Date)] $content"
    }

    $content | Out-File -Append -FilePath $LogFilePath
}


function Format-TimeDuration
{
    Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [TimeSpan]$timeSpan
    )
    return "$($timeSpan.Hours):$("{0:D2}" -f $timeSpan.Minutes):$("{0:D2}" -f $timeSpan.Seconds)"
}


function Test-Elevated
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}