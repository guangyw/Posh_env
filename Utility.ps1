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
