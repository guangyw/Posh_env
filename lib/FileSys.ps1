
function Merge-Path($OldPath, $IncPath)
{
  $MergedPath = ($IncPath -split ";") + ($OldPath -split ';') `
  |? {$_.Trim().Length -gt 0} `
  | Select-Object -Unique

  $NewPath = $MergedPath -join ";"

  Write-Verbose "New Path:"
  Write-Verbose $NewPath

  return $NewPath
}
