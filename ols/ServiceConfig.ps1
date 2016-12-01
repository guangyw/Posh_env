function Row {
  [PSCustomObject] @{
    Alias = $args[0]
    ServicePoolId = $args[1]
    Environment = $args[2]
    Cloud = $args[3]
  }
}

$ServicePools = @(
  # Alias   -  SerivicePoolId   -  Environment  -  Cloud
  # WorldWide
  Row "EUS-INT" "eus-000.ols.officeapps.live-int.com" "Int" "WorldWide";

  Row "NCUS-EDog" "ncus-zzz.ols.edog.officeapps.live.com" "EDog" "WorldWide";
  Row "SCUS-EDog" "scus-zzz.ols.edog.officeapps.live.com" "EDog" "WorldWide";
  Row "WUS-EDog" "wus-zzz.ols.edog.officeapps.live.com" "EDog" "WorldWide";

  Row "WUS-Prod" "wus-zzz.ols.officeapps.live.com" "Production" "WorldWide";
  Row "SCUS-Prod" "scus-zzz.ols.officeapps.live.com" "Production" "WorldWide";
  Row "NCUS-000-Prod" "ncus-000.ols.officeapps.live.com" "Production" "WorldWide";
  Row "NCUS-001-Prod" "ncus-001.ols.officeapps.live.com" "Production" "WorldWide";
  Row "NCUS-ZZZ-Prod" "ncus-zzz.ols.officeapps.live.com" "Production" "WorldWide";

  # BlackForest
  Row "DEC-Prod" "dec-000.ols.osi.office.de" "Production" "BlackForest";
  Row "DENE-Prod" "dene-000.ols.osi.office.de" "Production" "BlackForest";

  # Gallatin
  Row "SHA-EDog" "sha-ols.edog.officeapps.partner.office365.cn" "EDog" "Gallatin";
  Row "BJB-EDog" "bjb-ols.edog.officeapps.partner.office365.cn" "EDog" "Gallatin";
  Row "SHA-Prod" "sha-ols.officeapps.partner.office365.cn" "Production" "Gallatin";
  Row "BJB-Prod" "bjb-ols.officeapps.partner.office365.cn" "Production" "Gallatin"
)

function Get-ServicePools { $ServicePools }
