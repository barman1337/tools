$computerName = "MY-COMPUTER"
$comp = [ADSI]"LDAP://CN=$computerName,OU=Computers,DC=example,DC=com"
$acl = $comp.psbase.ObjectSecurity.Access
$acl | Where-Object { $_.ObjectType -eq "c90f336d-0b34-4d50-8a49-63b4a7f7e731" -and $_.ActiveDirectoryRights -match "ReadProperty" }
