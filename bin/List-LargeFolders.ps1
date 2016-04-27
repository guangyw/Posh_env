
param (
  [Parameter(Mandatory=$true)]
  [string]$Path
)

ls $Path -Dir `
| Get-DirStat `
| Sort-Object Size -Descending `
| Select FullName, ReadableSize
