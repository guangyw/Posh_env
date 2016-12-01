# Known issue: this doesn't output anything after a reboot
# In that case, either find the configs in another way
# Or warn the user that processes indeed exists

Get-WmiObject win32_process -Filter "name like 'w3wp.exe'" `
|% {
  # Write-Host $_.CommandLine
  if ($_.CommandLine -match '-ap "(\w+)-(\w*)-MSOSP(\d+)"')
  {
    [PSCustomObject] @{App="/$($matches[2])"; Name=$matches[1]; Port=$matches[3]; PID=$_.ProcessId;}
  }
  elseif ($_.CommandLine -match '-ap "Root-MSOSP(\d+)"')
  {
    [PSCustomObject] @{App='/'; Name=''; Port=$matches[1]; PID=$_.ProcessId;}
  }
} | Sort Port, PID
