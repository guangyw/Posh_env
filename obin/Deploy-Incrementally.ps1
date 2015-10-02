$deployedApps = @{}

Get-WebApplication |% {$deployedApps.Add($_.Name)}

#$installRoot = $env:INSTALLROOT
$installRoot = "e:\Office\Install"
$availableApps = Join-Path $installRoot x64\debug\devhosted_omex\en-us\Agents `
|? {}


echo $deployedApps
echo $availableApps