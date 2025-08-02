Get-ADComputer -Filter * -Properties DistinguishedName | ForEach-Object {
    $acl = Get-ACL ("AD:\" + $_.DistinguishedName)
    foreach ($ace in $acl.Access) {
        if ($ace.ActiveDirectoryRights -match "ReadProperty" -and $ace.ObjectType -eq "00000000-0000-0000-0000-000000000000" -or $ace.ObjectType -eq "bf967a86-0de6-11d0-a285-00aa003049e2") {
            # זו הגישה למאפיין כלשהו
            if ($ace.ObjectType -eq "e48d0154-bcf8-11d1-8702-00c04fb96050") {
                [PSCustomObject]@{
                    Computer     = $_.Name
                    Identity     = $ace.IdentityReference
                    Rights       = $ace.ActiveDirectoryRights
                    Inherited    = $ace.IsInherited
                }
            }
        }
    }
}
