# --------- ZLocation ---------

if (Get-Module ZLocation -ListAvailable) {
  # Import Z-Location
  Import-Module ZLocation
  Write-Host -Foreground Yellow "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations."
}

# --------- Posh-Git ---------

# TODO: consider eliminate the requirement for this
# (Write something better, or with better control)
if (Get-Module Posh-Git -ListAvailable) {
  Import-Module Posh-Git

  # Set up a simple prompt, adding the git prompt parts inside git repos
  function global:prompt {
      $realLASTEXITCODE = $LASTEXITCODE

      if (Get-GitDirectory) {
        Write-Host ">" -NoNewline
        Write-VcsStatus
        Write-Host ""
      }

      Write-Host "PS $pwd" -NoNewline

      $global:LASTEXITCODE = $realLASTEXITCODE

      return "> "
  }

  # Let's VSO style auth
  # Start-SshAgent -Quiet
}
