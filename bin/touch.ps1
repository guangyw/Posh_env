# There is built-in touch for PowerShell

param(
  [Parameter(Mandatory=$true)]
  [string]$FilePath
)

if (Test-Path $FilePath) {
  Write-Warning "File already exists: $FilePath"
  return
}

Write-Verbose "Touching $FilePath"
New-Item -ItemType File -Path $FilePath
