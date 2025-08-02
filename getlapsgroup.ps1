Get-Acl "AD:\CN=ComputerName,OU=YourOU,DC=domain,DC=com" |
    Select-Object -ExpandProperty Access |
    Where-Object { $_.ActiveDirectoryRights -match "ReadProperty" -and $_.ObjectType -eq "bf967a86-0de6-11d0-a285-00aa003049e2" } |
    Select-Object IdentityReference, ActiveDirectoryRights, ObjectType
