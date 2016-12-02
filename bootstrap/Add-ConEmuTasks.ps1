param (
  [Parameter(Mandatory=$true)]
  [ValidateScript({Test-Path $_})]
  [string]$ConEmuSettingPath
)

Set-StrictMode -Version latest

$Palettes = @(
  "Base16",
  "ConEmu",
  "Monokai",
  "Solarized",
  "Solarized Git",
  "Solarized (John Doe)",
  "SolarMe",
  "Tomorrow Night",
  "Tomorrow Night Bright",
  "Tomorrow Night Eighties",
  "Twilight",
  "Ubuntu"
)

function Get-RandomPalette {
  $Palettes | Get-Random
}

function Get-TimeString {
  (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()
}

. $PsScriptRoot\..\config\ManageConfig.ps1

$xPsStartPath = (Get-Item $PsScriptRoot\..\xPsStart.ps1).FullName

$environments = Get-PsEnvironments

$settingDoc = [xml](cat $ConEmuSettingPath)

$taskNodes = $settingDoc.key.key.key.key `
|? {$_.name -eq "Tasks"}

$existingTaskNames = $taskNodes.Key.value `
|? {$_.name -eq 'name'} `
| Select -Expand data

Add-Type -AssemblyName "System.Xml"

function ConvertFrom-TaskXml {
  param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Xml.XmlElement]$taskDoc
  )

  process {
    [PsCustomObject] @{
      TaskId = $taskDoc.name
      Modified = $taskDoc.modified
      Build = $taskDoc.build
      Name = $taskDoc.value |? {$_.name -eq "Name"} | Select -Expand data
      Flags = $taskDoc.value |? {$_.name -eq "Flags"} | Select -Expand data
      HotKey = $taskDoc.value |? {$_.name -eq "HotKey"} | Select -Expand data
      GuiArgs = $taskDoc.value |? {$_.name -eq "GuiArgs"} | Select -Expand data
      Cmd1 = $taskDoc.value |? {$_.name -eq "Cmd1"} | Select -Expand data
      Active = $taskDoc.value |? {$_.name -eq "Active"} | Select -Expand data
      Count = $taskDoc.value |? {$_.name -eq "Count"} | Select -Expand data
    }
  }
}

$templateTaskNode = $taskNodes.key[-1].CloneNode($true) # Deep clone

function ConvertTo-TaskXml {
  param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [PsCustomObject]$task
  )

  Write-Host "Convert to TaskXml:"
  Write-Host "$task"

  # TODO Start Debug Session
  #PowerShell -NoExit

  $taskDoc = $templateTaskNode.CloneNode($true)

  $taskDoc.name = $task.TaskId
  $taskDoc.modified = $task.Modified
  $taskDoc.build = $task.Build

  foreach ($property in @("Name", "Flags", "HotKey", "GuiArgs", "Cmd1", "Active", "Count")) {
    $elem = $taskDoc.value `
    |? {$_.name -eq $property}

    $elem.data = $task.$property
  }

  $taskDoc
}

# We are going to mutate $taskNodes here
foreach ($env in $environments) {
  $taskName = "{PsEnv::$($env.Name)}"

  if ($existingTaskNames -contains $taskName) {
    Write-Verbose "Skip adding task $taskName because it exists"
  }

  Write-Verbose "Adding task $taskName"

  $palette = Get-RandomPalette
  $startupCmd = "*PowerShell.exe -NoExit -new_console:P:`"<$palette>`" -File `"$xPsStartPath`" -EnvironmentName $($env.Name)"

  $tasks = $taskNodes.key | ConvertFrom-TaskXml
  Write-Verbose "Task count $($tasks.Count)"
  Write-Verbose "Last Task: $($tasks[-1].TaskId)"

  $task = [PsCustomObject] @{
      TaskId = "Task$([int]$tasks[-1].TaskId.Substring(4) + 1)"
      Modified = Get-TimeString
      Build = $templateTaskNode.build
      Name = $taskName
      Flags = "00000000"
      HotKey = "00000000"
      GuiArgs = ""
      Cmd1 = $startupCmd
      Active = "0"
      Count = "1"
  }

  $taskDoc = ConvertTo-TaskXml $task

  $taskNodes.AppendChild($taskDoc) | Out-Null
}

# Update last modified time
($taskNodes.value |? {$_.name -eq 'Count'}).data = $taskNodes.key.Count.ToString()
$taskNodes.modified = Get-TimeString
$settingDoc.key.key.key.modified = Get-TimeString

Copy-Item -Path $ConEmuSettingPath -Destination ($ConEmuSettingPath + ".backup") -Force
$settingDoc.OuterXml | Out-File $ConEmuSettingPath -Force -Encoding UTF8

return $settingDoc
