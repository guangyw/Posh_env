param (
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName)]
  [Alias("FullName")]
  [string]$Path
)

Begin {
  . "$PsScriptRoot\..\lib\Utility.ps1"

  # TODO: this approach doesn't work for $env:LocalAppData and some other folders
  $FSO = New-Object -Com Scripting.FileSystemObject
}

Process {
  #Write-Warning $Path

  $Folder = Get-Item $Path
  $FullName = $Folder.FullName
  $DirStat = $FSO.GetFolder($FullName)

  [PSCustomObject] @{
     Name = $Folder.Name;
     FullName = $Folder.FullName;
     Folder = $Folder;
     Size = $DirStat.Size;
     ReadableSize = Format-Size $DirStat.Size;
   }
}

End {
  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($FSO) | Out-Null
  #$FSO.Dispose()
}
