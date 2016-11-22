# load the dependent OSI modules
Import-Module Slingshot
Import-Module OsiSecretManagement

$outputFile = ".\UsageData_FromAirs.csv"
touch $outputFile

#$startDateTime = $endDateTime.AddMonths(-1)
$startDateTime = [System.DateTime]::UtcNow.AddDays(-30)
$endDateTime = $startDateTime.AddDays(10)

$airsUri = "http://airsapi/API/AIRSRest.svc/"

# Get the shared OSI certificate used to authenticate calls to the Airs web api
$cert = Convert-OsiSecretToCertificate -Category OsiSslCert -Id Int.Shared.All.AirsApiCertificate

# Select one or service using Slingshot
$serviceList = Get-OsiService -ServiceId Claret

Write-Host "Services $($serviceList)"

# For each service, use Slingshot to get a list of subscriptions (for any environment), export AIRs data
ForEach($service in $serviceList)
{
    write-host "Pulling data for $($service.DisplayName) [$($service.ServiceId)]:" -ForegroundColor Yellow
    Get-OsiSubscription -ServiceId $service.ServiceId | ForEach-Object {

        $subscriptionId = $_.SubscriptionId
        $environment = $_.Environment
        $serviceId = $service.ServiceId
        $serviceName = $service.DisplayName

        # build the uri, request data from Airs
        $uri = "$($airsUri)rest/usage/V2/guid=$($subscriptionId)$("&")startdate=$($startDateTime.ToString("yyyy-MM-dd"))$("&")enddate=$($endDateTime.ToString("yyyy-MM-dd"))"

        Write-Host "AIRS URL $uri" -ForegroundColor Yellow

        Write-Host "Querying AIRS for subscription $subscriptionId ..."

        $response = Invoke-WebRequest -Uri $uri -Certificate $cert

        # Write-Host $response

        $usageRecords = (ConvertFrom-Json $response).GetUsagebyguidV2Result

        if ($usageRecords.Count -eq 0)
        {
            write-host "0 records found." -ForegroundColor Yellow
            continue
        }

        Write-Host "$($UsageRecords.Count) records found ...."

        # Add the service and environment context
        $usageRecords = $usageRecords `
            | Add-Member -PassThru -MemberType NoteProperty -Name ServiceId -Value $serviceId `
            | Add-Member -PassThru -MemberType NoteProperty -Name ServiceName -Value $serviceName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Environment -Value $environment

        # Select columns, export records to the output file
        $records = $usageRecords `
                    | Select-Object `
                        ServiceName, `
                        ServiceId, `
                        Environment, `
                        @{Name='SubscriptionId'; Expression={$_.SubscriptionGUID}}, `
                        @{Name='PCCode'; Expression={$_.L7PCCode}}, `
                        @{Name='Location'; Expression={$_.Datacenter}}, `
                        @{Name='AzureService'; Expression={ $_.Service }}, `
                        ServiceResource, `
                        ServiceType, `
                        @{Name='Region'; Expression={ $_.ServiceRegion }}, `
                        Component, `
                        @{Name='TotalCharges'; Expression={ $_.ConsumptionChargesInternal }}, `
                        @{Name='TotalQuantity'; Expression={ $_.ConsumedQuantity }}, `
                        UsageDate

        $records | Export-Csv $outputFile -NoTypeInformation -Append

        Write-Host -ForegroundColor Green 'Done'

        $records
    }
}
