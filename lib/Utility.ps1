function Select-First
{
  [CmdletBinding()]
  param(
  [Parameter(Mandatory=$false, Position=1)]
  [int]$Count = 1,

  [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
  $objects
  )

  Begin{
    # echo "[Debug] [In Begin] objects:$objects";
    $Processed = 0;
  }

  Process{
    # echo "[Debug] [In Process] objects:$objects";
    if ($processed -ge $count)
    {
      return;
    }
    $Processed += 1
    $objects
  }

  End{
    # echo "[Debug] [In End] objects:$objects";
    # echo "[Debug] [In End] Processed $Processed"
  }
}

Set-Alias first Select-First

# **Shamelessly copied from latkin's blog**
# converts text to objects via regex,
# with properties corresponding to capture groups
filter ro
{
  param($pattern)

  if($_ -match $pattern)
  {
    $result = @{}
    $matches.Keys |?{ $_ } |%{
        $raw = $matches[$_]
        $asInt = 0
        $asFloat = 0.0
        $asDate = [datetime]::Now
        if([int]::TryParse($raw, [ref] $asInt)){ $result[$_] = $asInt }
        elseif([double]::TryParse($raw, [ref] $asFloat)){ $result[$_] = $asFloat }
        elseif([datetime]::TryParse($raw, [ref] $asDate)){ $result[$_] = $asDate }
        else{ $result[$_] = $raw }
    }
    [pscustomobject]$result
  }
}


function assoc
{
  param(
  [Parameter(Mandatory=$false, Position=1)]
  [Alias("ext")]
  [string]$Extension,

  [Parameter(Mandatory=$false, Position=2)]
  [Alias("ftype")]
  [string]$FileType
  )

  $outputPattern = "(?<Ext>.+)=(?<FileType>.+)$"

  if (-not $FileType)
  {
    cmd /c assoc $Extension | ro $outputPattern
  }
  else
  {
    cmd /c assoc "$Extension=$FileType" | ro $outputPattern
  }
}


function ftype
{
  param(
  [Parameter(Mandatory=$false, Position=1)]
  [Alias("ftype")]
  [string]$FileType,

  [Parameter(Mandatory=$false, Position=2)]
  [Alias("cmd")]
  [string]$Command
  )

  $outputPattern = "(?<FileType>.+?)=(?<Command>.+)$"

  if (-not $Command)
  {
    cmd /c ftype $FileType | ro $OutputPattern | Select FileType, Command
  }
  else
  {
    cmd /c ftype "$FileType=$Command" | ro $OutputPattern
  }
}


function Get-UpTime
{
  (Get-Date) - (Get-CimInstance Win32_operatingSystem).lastbootuptime
}


function Paket
{
  if (-not (Test-Path '.\.paket\'))
  {
    Write-Error "Not in a Paket land"
    return
  }

  $paketExe = '.\.paket\paket.exe'
  $paketBootstrapper = '.\.paket\paket.bootstrapper.exe'
  if (-not (Test-Path $paketExe))
  {
    # Paket is not bootstrapped
    if (-not (Test-Path $paketBootstrapper))
    {
      Write-Error "Paket bootstrapper not found"
      return
    }

    & $paketBootstrapper
    if (-not (Test-Path $paketExe))
    {
      Write-Error "Paket bootstrapping failed"
      return
    }
  }

  # finally run paket
  & $paketExe $args
}


function Set-Title
{
  param(
    [string]$title
  )

  $Host.UI.RawUI.WindowTitle = $title

  # Set the env var 'title', respected by otools
  $Env:Title = $title
}


function Format-Size
{
  param(
    [Parameter(Mandatory=$true)]
    [Decimal]$NumBytes
  )

  if ($NumBytes -ge 1024 * 1024)
  {
    return "{0:f} MB" -f ($NumBytes / (1024 * 1024))
  }
  elseif ($NumBytes -ge 1024)
  {
    return "{0:f} KB" -f ($NumBytes / (1024))
  }
  else
  {
    return "{0:f} B" -f $NumBytes
  }
}


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
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
}
