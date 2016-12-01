# PsEnv - PowerShell Environment

PowerShell configurations and scripts for both work and play.

## TODOs

- Environment Caching
- Auto environment switch as you change directory
  > Use something as: Posh-Env, Pop-Env

- Environment switch - e.g. Visual Studio Build Environment
  > Environment will need to be stacked upon each other

// Nice to have, maybe too much
- PsEnvCheck for comprehensive environment setup check
- Environment viewer and diagnostics
- Environment diff

- Allow the configuration of your fav editor (in PreConfig.ps1, or force as user config?)

- GetIp

# DONEs

- oPsStart should work for all enlistment (sd client)

- Define client specific settings in separate config files
Comment: there should hardly be any client specific settings
         for now let's use env xml to store the customization

- Should have a separate file to define common utilities for all
- Have a separate file to define common utilities for all Office enlistments

- autojump replacement (Using Z-Location for now)
