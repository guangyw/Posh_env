
param (
  [Parameter(Mandatory=$false)]
  [string]$token
)

Set-StrictMode -Version "Latest"

. $PsScriptRoot\..\ols\OlsDevConfig.ps1

function Get-DllPaths {
  param (
    [string]$Directory
  )
  Get-ChildItem $Directory -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue `
  |? {$_.Name.StartsWith("Ols")}
}

function Invoke-QuickBuild {
  $currentPath = $pwd.Path
  if (-not $currentPath.StartsWith($env:SrcRoot)) {
    Write-Warning "Outside of SrcRoot $($env:SrcRoot), exit ..."
    Exit 1 # will this exit this entire script?
  }

  $projectName = $currentPath.Substring($env:SrcRoot.Length).Trim('\').Split('\')[0]
  Write-Verbose "ProjectName: $projectName"

  # TODO probably not the same case when building olssetup
  # First try x-none, then try en-us
  $targetPath = Join-Path $env:SrcRoot "..\target\x64\debug\$projectName\x-none"
  Write-Verbose "TargetPath: $targetPath"

  <#
  $buildDlls = Get-ChildItem "." -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue `
  |% {[xml](Get-Content $_.FullName)} `
  |% {$_.Project.PropertyGroup[0].AssemblyName} `
  |% {"$_.dll"}
  #>

  $existingDlls = Get-DllPaths -Directory $targetPath
  Write-Verbose "Existing Dlls"
  $existingDlls |% { Write-Verbose "$($_.Fullname), $($_.LastWriteTime)" }

  $existingDllsIndexed = @{}
  $existingDlls |% { $existingDllsIndexed[$_.FullName] = $_ }

  # ------ Building --------
  $startTime = [DateTime]::Now
  quickbuild $args | Write-Host
  $endTime = [DateTime]::Now
  $duration = $endTime - $startTime

  Write-Host "Build starts: $startTime"
  Write-Host "Build ends: $endTime"
  Write-Host "Duration: $duration"
  # ------ End Build --------

  Get-DllPaths -Directory $targetPath `
  |? {
     if (-not $existingDllsIndexed.ContainsKey($_.FullName)) {
       $true
     } else {
       $_.LastWriteTime -ne $existingDllsIndexed[$_.FullName].LastWriteTime
     }
  } `
  |% {
    Write-Verbose "New Dll $($_.FullName), Time: $($_.LastWriteTime)"
    $_
  } `
  | Select FullName, LastWriteTime
}

switch ($token) {
  "nocache" {
    Invoke-QuickBuild "-CacheType", "None"
  }
  "ed" {
    BuildEd | Write-Host
  }
  default {
    Invoke-QuickBuild
  }
}
