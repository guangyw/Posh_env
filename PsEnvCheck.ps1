# PsEnvCheck.ps1

<#
  Check current environment setup
#>

# Check installed programs
function Check-Executable($exe, $cmd) {
  $info = Get-Command $exe
  if ($info) {
    Write-Host "$exe is available"
    if ($cmd) { Invoke-Expression $cmd }
  } else {
    Write-Host "$exe is not found"
  }
}

Check-Executable "java" "java -version"
Check-Executable "scala" "scala -version"
Check-Executable "fsi"
Check-Executable "python" "python --version"

# Check availability of environment variables
# JAVA_HOME, SCALA_HOME, PYTHONPATH, PYTHONHOME

# Check the system PATH
# 1. Is any path invalid?
# 2. Is any path duplicated
