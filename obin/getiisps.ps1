Get-WmiObject win32_process -Filter "name like 'w3wp.exe'" `
|% {
  if ($_.CommandLine -match '-ap "(\w+)-(\w*)-MSOSP(\d+)"')
  {
    New-Object PSObject -Property @{App="/$($matches[2])"; Name=$matches[1]; Port=$matches[3]; PID=$_.ProcessId;}
  }
  elseif ($_.CommandLine -match '-ap "Root-MSOSP(\d+)"')
  {
    New-Object PSObject -Property @{App='/'; Name=''; Port=$matches[1]; PID=$_.ProcessId;}
  }
} | Sort Port, PID
