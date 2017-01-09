param (
  [Parameter(Mandatory=$true, ParameterSetName="Release")]
  [string]$BuildNumber,

  [Parameter(Mandatory=$false, ParameterSetName="Release")]
  [ValidateSet("WorldWide", "Gallatin", "NewGallatin", "BlackForest")]
  [string]$Cloud,

  [Parameter(Mandatory=$true, ParameterSetName="Release")]
  [ValidateSet("Int", "EDog", "Prod")]
  [string]$Environment,

  [Parameter(Mandatory=$true, ParameterSetName="Test")]
  [ValidateSet("Local", "PrCloud", "PrCloud-Scaled")]
  [string]$TestEnvironment
)

function Get-BuildType {
  param (
    [Parameter(Mandatory=$true)]
    $BuildNumber
  )

  if ($BuildNumber -match "^16\.0\.") {
    "official"
  } else {
    "private"
  }
}

if ($TestEnvironment) {
  switch ($TestEnvironment) {
    "Local" {
      Write-Host "Deploying to DevFabric" -ForegroundColor Green
      devosi deploydev debug Ols-DevFabric
    }
    "PrCloud" {
      Write-Host "Deploying to SingleBox PR Cloud" -ForegroundColor Green
      devosi checkout Ols-SingleBox-Cloud
      devosi deploycloud debug Ols-SingleBox-Cloud
    }
    "PrCloud-Scaled" {
      Write-Host "Deploying to Scaled PR Cloud" -ForegroundColor Green
      devosi checkout Ols-ScaledPR-Cloud
      devosi deploycloud debug Ols-ScaledPR-Cloud
    }
  }
} else {
  switch -WildCard ("$Environment|$Cloud") {
    "Int|*" {
      Write-Host "Deploying to WorldWide Int" -ForegroundColor Green
      $BuildType = Get-BuildType $BuildNumber
      $SpecFilePath = "\\ocentral\Build\VSTSCICDPrototype\ols\$BuildType\$BuildNumber\target\x64\Ship\olssetup\en-us\setup\WARM\Environments\Ols-Int-Cloud\DeploymentSpec-AllRegions.xml"
    }

    "EDog|Gallatin" {
      Write-Host "Deploying to Gallatin EDog" -ForegroundColor Green
      $SpecFilePath = "\\o\tenants\ols\$BuildNumber\releases\hosted\en-us\$($BuildNumber)_OsiolsChina_none_ship_x64_en-us\warm\environments\OlsCn-ChinaEDog-Cloud\DeploymentSpec-AllRegions.xml"
    }

    "EDog|NewGallatin" {
      Write-Host "Deploying to New Gallatin EDog" -ForegroundColor Green
      $SpecFilePath = "\\o\tenants\ols\$($BuildNumber)\releases\hosted\en-us\$($BuildNumber)_Osiols_none_ship_x64_en-us\warm\environments\Ols-ChinaEdog-Cloud\DeploymentSpec-AllRegions.xml"
    }

    "EDog|WorldWide" {
      Write-Host "Deploying to WorldWide EDog" -ForegroundColor Green
      $BuildType = Get-BuildType $BuildNumber
      $SpecFilePath = "\\ocentral\Build\VSTSCICDPrototype\ols\$BuildType\$BuildNumber\target\x64\Ship\olssetup\en-us\setup\WARM\Environments\Ols-EDog-Cloud\DeploymentSpec-AllRegions.xml"
    }

    "Prod|Gallatin" {
      Write-Host "Deploying to Gallatin Production" -ForegroundColor Green
      $SpecFilePath = "\\o\tenants\ols\$BuildNumber\releases\hosted\en-us\$($BuildNumber)_OsiolsChina_none_ship_x64_en-us\warm\environments\OlsCn-ChinaProduction-Cloud\DeploymentSpec-AllRegions.xml"
    }

    "Prod|BlackForest" {
      Write-Host "Deploying to BlackForest Production" -ForegroundColor Green
      $SpecFilePath = "\\o\tenants\ols\$($BuildNumber)\releases\hosted\en-us\$($BuildNumber)_Osiols_none_ship_x64_en-us\warm\environments\Ols-GermanyProduction-Cloud\DeploymentSpec-AllRegions.xml"
    }

    "Prod|WorldWide" {
      Write-Warning "Trigger worldwide production deployment from this cmdlet is forbidded"
      return
    }

    default {
      Write-Error "Unrecognized environment $environment and cloud $cloud"
      return
    }
  }

  Write-Host "Triggering WARM deployment ..." -ForegroundColor Green
  Write-Host "SpecFilePath: $SpecFilePath"
  Start-WarmDeployment -SpecFilePath $SpecFilePath
}
