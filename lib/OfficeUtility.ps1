function Get-HexPuid {
  $hex = "{0:X}" -f [UInt64]$args[0]
  Write-Output "Hex Puid: $hex"
  $hex | clip
}
