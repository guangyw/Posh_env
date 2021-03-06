# Run static method within a DLL with ease

[CmdletBinding()]
param (
	[Parameter(Mandatory=$true, Position=0)]
  [Alias("Path", "Dll", "File")]
	[String]$DllPath,

	[Parameter(Mandatory=$false, Position=1)]
	[String]$MethodName,

	[Parameter(Mandatory=$false, Position=2)]
  [Alias("Args", "Params")]
	[Object[]]$ProgramArgs
)

if (-not (Test-Path $DllPath)) {
  Write-Error "File not found $DllPath"
  Exit
}

$DllPath = (ls $DllPath).FullName

# TODO: list out all possible executable functions within that DLL

# TODO: use a separate AppDomain
# But why are the issues in reusing the current AppDomain
# TODO: run in a different process
# because e.g. if there is an infinite loop with the DLL, you can kill it
# without kill the hosting shell

# TODO: How to figure out all the dependencies, if DLL is not a standalone one


function Exit-Gracefully
{
  if ($AppDomain) {
    [AppDomain]::Unload($AppDomain)
  }
  Exit
}

function Select-Method($types, $className, $methodName)
{
  Write-Verbose "Select method to invoke in $($types)"
  if ($className) {
    # ClassName exists means MethodName is not inferred but passed
    # TODO: the method does not need to be a static one as long as default ctr is provided
    foreach ($type in ($types)) {
      if ($type.FullName.EndsWith($className)) {
        $methodInfo = $type.GetMethod($methodName, ([Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::Public -bor [Reflection.BindingFlags]::NonPublic))
        if ($methodInfo) {
          return $methodInfo
        }
      }
    }
    Write-Error "Cannot find desired class: $className.$methodName"
  } else {
    foreach ($type in ($types)) {
      Write-Verbose "$($type.FullName) Methods $($type.GetMethods().Name)"
      $methodInfo = $type.GetMethod($methodName, ([Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::Public -bor [Reflection.BindingFlags]::NonPublic))
      if ($methodInfo) {
        return $methodInfo
      }
    }
    Write-Error "Cannot find class with static method $methodName"
  }
  Exit-Gracefully
}

function Invoke-Method($methodInfo, $_args)
{
  # TODO: check the argument count
  # If the argument is (String[] args), pass in the script's $progargs
  # Otherwise print out the helpful information
  $methodInfo.Invoke($null, $_args)
}

# ---------------------------------------------------------------------------

#$AssemblyName = [Reflection.AssemblyName]::GetAssemblyName($DllPath)
<#
$AppDomainSetup = New-Object AppDomainSetup
$AppDomainSetup.ApplicationBase = [IO.Path]::GetDirectoryName($DllPath)
$AppDomain = [AppDomain]::CreateDomain("PoshEnv.RunDll", [AppDomain]::CurrentDomain.Evidence, $AppDomainSetup)
#>
$appDomainSetup = New-Object AppDomainSetup
$appDomainSetup.ApplicationBase = (Get-Location).Path

$AppDomain = [AppDomain]::CreateDomain("CustomDomain_PsRunDLL", $null, $appDomainSetup)

Write-Verbose "AppDomain BaseDirectory $($AppDomain.BaseDirectory)"
$AssemblyBytes = [IO.File]::ReadAllBytes($DllPath)
#$SymbolsBytes = [IO.File]::ReadAllBytes((ls ".\Main.pdb").FullName)
Try {
	# $dll = $AppDomain.Load($AssemblyBytes)
	# $dll = [Reflection.Assembly]::LoadFrom($DllPath)
	$dll = [Reflection.Assembly]::Load($AssemblyBytes)
	$types = $dll.GetTypes()
} Catch {
	Write-Error $_.Exception
	Write-Error $_.Exception.LoaderExceptions
	return $_
}

if (-not $MethodName) {
  # use Main as the default entry point name
  $MethodName = "Main"
}

$className = ''
$periodIndex = $MethodName.LastIndexOf(".")
if ($periodIndex -ne -1) {
  $className = $MethodName.Substring(0, $periodIndex)
  $MethodName = $MethodName.Substring($periodIndex + 1)
}

Write-Verbose "ClassName: $className"
Write-Verbose "MethodName: $methodName"
$method = Select-Method $types $className $methodName

Invoke-Method $method $ProgramArgs

# Exit-Gracefully
