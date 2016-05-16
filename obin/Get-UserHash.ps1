<#
This is OMEX implementation specific hashing of user identities
#>

﻿param(
    [Parameter(Mandatory=$true)]
    [string]$puid
)

$HashProvider = New-Object Security.Cryptography.SHA256CryptoServiceProvider;

$bytes = [Text.Encoding]::UTF8.GetBytes($puid);
$hashedBytes = $HashProvider.ComputeHash($bytes);
$encodedHash = [Convert]::ToBase64String($hashedBytes);


echo "1_$encodedHash";
