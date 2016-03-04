# Playground

# Consider the concept of profile
# PsStart and oPsStart essentially load different profiles
# profiles can have some hierachy, they are composable

# How easy it is to switch profile

param (
  [string]$ProfileName = "Hew-Dev"
)

Write-Host "Profile is $ProfileName"

# Function parameters weirdness
function Test-Args($a, $b) {
  Write-Host "a: $a"
  Write-Host "b: $b"
}
Test-Args "a" "b"
Test-Args("a", "b") # why this is so wrong?
<# OUTPUT:
a: a
b: b
a: a b
b:
#>
