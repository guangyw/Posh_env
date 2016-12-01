
# TODO: proper migration

if ($env:LIB -eq "--must-override-in-makefile--") {
  # I think this is a bad decision, developers are not monkeys
  $env:LIB = ""
}

function vsomex { devenv "$env:SrcRoot\omexservices\omexservices.sln" }
function vsretailer { devenv "$env:SrcRoot\omexservices\omexretailer.sln" }
function vsshared { devenv "$env:SrcRoot\omexshared\omexshared.sln" }
function vstest { devenv "$env:SrcRoot\omexservices\omexservicestest.sln" }
function vstelemetry { devenv "$env:SrcRoot\omexservices\telemetry\OmexTelemetry.sln" }
function vsreconciler { devenv "$env:SrcRoot\omexservices\reconciler.sln" }

# ------------------------------------------
Push-Location $env:SrcRoot;

$sdinfo = sdinfo
$SdClientName = $sdinfo."Client name"

newline "Welcome to PsEnlistment ($SdClientName)"
omotd -tip
