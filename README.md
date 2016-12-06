# PsEnv - PowerShell Environment

PowerShell configurations and scripts for both work and play.

## TODOs

- Auto environment switch as you change directory (?)
  > Use something as: Posh-Env, Pop-Env

- Environment switch - e.g. Visual Studio Build Environment
  > Environment will need to be stacked upon each other
  > Switch-Environment OLS-GIT
  > (If it's cheap to init, it should be cheap to switch)

- Auto detect current environment change
  > git post commit hook so that, if a change to develop requires
  > re-init of the environment, something will show in the status badge

- Timeout on git fetch status used by posh-git

// Nice to have, maybe too much
- PsEnvCheck for comprehensive environment setup check
  > the idea itself is heavily influenced from ohome/ocheck
  > which themselves are not good ideas

- Environment viewer and diagnostics
- Environment diff

- Create environment for PsEnv itself for developing and testing
- Respect ConEmu palette configs
