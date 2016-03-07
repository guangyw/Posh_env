# Get list opened files grouped by changelists in current enlistments
# Contact: Odin Wang (hew)

# TODO: implement custom formating

function newList {New-Object System.Collections.ArrayList}

function stripPathOutput {
    # TODO: strip according to $pwd
    $path = $args[0]
    if ($path -match "^//depot/devmainoverride/tenantomex/")
    {
        return $path.Substring(35)
    }
    return $path
}

$changes = @{default=@{
    Files=newList;
    ChangeNo="default";
    Timestamp=Get-Date "0001/01/01 00:00:00"
  }}

$changesOutput = sd changes -l -c hew-dev -s pending
# This command gives no output if there is no change list
if ($changesOutput) {
  $regexPtn = 'Change (\d+) on (\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) by [\w\\@-]+ \*pending\*\s+(.+?)\s+?(?=Change \d+ on \d{4}|$)'
  $parsedChanges = [Regex]::Matches($changesoutput, $regexPtn)

  $parsedChanges `
    |% { @{
      ChangeNo=$_.Groups[1].Value;
      Timestamp=Get-Date $_.Groups[2].Value;
      Description=$_.Groups[3].Value;
      Files=newList;
    }} `
    |% { $changes.Add($_.ChangeNo, $_) }
}

$openedOutput = sd opened

$openedOutput |% {
    $_ -match "([\w\d\./]+?)#(\d+) - ([\w]+)(?: default)? change (\d*)" | Out-Null
    $Path = $matches[1]
    $Revision = $matches[2]
    $Mode = $matches[3]
    $ChangeNo = $matches[4]
    if (-not $ChangeNo) {$ChangeNo = "default"}
    $changes[$ChangeNo].Files.Add(@{"Path"=$Path; "Mode"=$Mode}) | Out-Null
}

$changes.Values `
| Sort {$_.Timestamp} `
|? {$_.Files} `
|% {
if ($_.ChangeNo -eq "default") {
    echo "Default Changelist --------- "
} else {
    echo "CL $($_.ChangeNo) - $($_.Description)"
}
echo ''
$_.Files | Sort {$_.Mode + $_.Path} |% {
  "$($_.Mode) - $(stripPathOutput($_.Path))" | echo
}
echo ''
}
