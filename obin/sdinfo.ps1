
$result = @{}

sd info `
|% {
  $kv = $_ -split ":", 2
  $result[$kv[0].Trim()] = $kv[1].Trim()
}

[PsCustomObject]$result
