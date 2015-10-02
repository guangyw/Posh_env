# Get last download file (from download location) to here

$downloadLocations = Join-Path $env:USERPROFILE "Downloads"

$lastDownloadedFile = $downloadLocations `
| ls -File `
| Sort LastWriteTime -Descending `
| Select -First 1

if ($pwd -eq (Split-Path $lastDownloadedFile -Parent))
{
    "File already in current folder"
}

Move-Item $lastDownloadedFile.FullName $pwd.Path -Force -Verbose
