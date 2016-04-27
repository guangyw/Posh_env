$otoolsincdir = "$env:otools\inc\otools"
$SyncLabelFilePath = "$otoolsincdir\OfficeSyncLabel.txt"
$LabVersionFilePath = "$otoolsincdir\OfficeLabVersion.txt"

function Get-BuildVer($BuildVerFilePath) {
  $d = @{}
  foreach ($line in (cat $BuildVerFilePath)) {
    if ($line.StartsWith("#define")) {
      #Write-Host $line
      $_, $key, $value = $line -split "\s",3
      $key = $key.Trim()
      $value = $value.Trim()
      $d[$key] = $value
    }
  }

  return $d['rmj'], $d['rmm'], $d['rup'], $d['rpr'] -join '.'
}

$SyncLabel = cat $synclabelfilepath;
$SyncLabel -match "[\w_]*?(\d+_\d+_\d+_\d+)"
$BuildVer = $matches[1] -replace '_', '.'

return New-Object PSObject -Property `
   @{
     BuildVer = $BuildVer;
     BaseBuildVer = Get-BuildVer $LabVersionFilePath;
     SyncedLabel = $SyncLabel;
   }
