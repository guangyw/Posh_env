# --------- ZLocation ---------

if (Get-Module ZLocation -ListAvailable) {
  # Import Z-Location
  Import-Module ZLocation
  Write-Host "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations." -Foreground Cyan
}

# --------- Posh-Git ---------

if (Get-Module Posh-Git -ListAvailable) {
  Import-Module Posh-Git

  function global:prompt {
      $realLASTEXITCODE = $LASTEXITCODE

      Write-Host "[" -NoNewline -ForegroundColor Yellow
      Write-Host "$($global:_PsEnv_Name)" -NoNewline -ForegroundColor Blue
      Write-Host "]" -NoNewline -ForegroundColor Yellow

      $gitDir = Get-GitDirectory
      if ($gitDir) {
        Write-VcsStatus

        $gitRoot = Get-Item (Split-Path -Parent $gitDir)
        $envRoot = Get-Item ($global:_PsEnv_EnvConfig.Root)

        # TODO [bug] FR shouldn't show when the env is not GIT version controlled
        if ($gitRoot.FullName -ne $envRoot.FullName) {
          Write-Host " !FR!" -NoNewline -ForegroundColor Yellow
        }
      }

      Write-Host ""

      Write-Host "PS $pwd" -NoNewline

      $global:LASTEXITCODE = $realLASTEXITCODE

      return "> "
  }

  # Let's use VSO style auth
  # Start-SshAgent -Quiet
}

# --------- PsReadline ---------

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Set-PSReadlineOption -EditMode Emacs
}
