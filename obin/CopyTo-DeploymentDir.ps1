
param (
  [Parameter(Mandatory=$true)]
  [string]$AgentBinPath,

  [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
  [string]$FullName
)

process {
  Copy-Item -Verbose -Force $FullName $AgentBinPath
}
