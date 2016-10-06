# Import a CSV file exported by COSMOS

# Read the header
# Return PSCustomObject (what could be optimized? Can this be homogeneous?)
# Auto convert DateTime types (Shouldn't this be done as part of ScopePlay?)

param(
  [Parameter(Mandatory=$true)]
  [string]$Path
)

$rows = Import-Csv $Path

# Skip the header
$rows | Select -Skip 1
