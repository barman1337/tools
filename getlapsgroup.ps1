$guid = "bf967a86-0de6-11d0-a285-00aa003049e2"  # GUID for ms-Mcs-AdmPwd
(Get-Acl ("AD:\" + $dn)).Access |
    Where-Object { $_.ObjectType -eq $guid -and $_.ActiveDirectoryRights -match "ReadProperty" } |
    Select-Object IdentityReference, ActiveDirectoryRights
