Get-Service `
|? {$_.Name -in 'WAS', 'w3svc', 'w3logsvc', 'NetPipeActivator', 'TapiSrv', 'aspnet_state'}
