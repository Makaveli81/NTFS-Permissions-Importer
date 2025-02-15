# Chemin vers le fichier CSV
$csvPath = "C:\Export\permissions_list.csv"

# Fonction pour mapper les valeurs de FileSystemRights du CSV aux valeurs valides
function Get-FileSystemRights {
    param (
        [string]$rightsString
    )
    $rights = 0
    $rightsString.Split(",") | ForEach-Object {
        switch ($_ -replace '\s+', '') {
            "FullControl" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::FullControl }
            "Modify" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::Modify }
            "ReadAndExecute" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::ReadAndExecute }
            "ListDirectory" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::ListDirectory }
            "Read" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::Read }
            "Write" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::Write }
            "Synchronize" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::Synchronize }
            "AppendData" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::AppendData }
            "CreateFiles" { $rights = $rights -bor [System.Security.AccessControl.FileSystemRights]::CreateFiles }
            default { throw "Valeur de FileSystemRights non valide : $_" }
        }
    }
    return $rights
}

# Fonction pour mapper les valeurs de InheritanceFlags
function Get-InheritanceFlags {
    param (
        [string]$flagsString
    )
    $flags = 0
    $flagsString.Split(",") | ForEach-Object {
        switch ($_ -replace '\s+', '') {
            "ContainerInherit" { $flags = $flags -bor [System.Security.AccessControl.InheritanceFlags]::ContainerInherit }
            "ObjectInherit" { $flags = $flags -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit }
            "None" { $flags = $flags -bor [System.Security.AccessControl.InheritanceFlags]::None }
            default { throw "Valeur de InheritanceFlags non valide : $_" }
        }
    }
    return $flags
}

# Fonction pour mapper les valeurs de PropagationFlags
function Get-PropagationFlags {
    param (
        [string]$flagsString
    )
    $flags = 0
    $flagsString.Split(",") | ForEach-Object {
        switch ($_ -replace '\s+', '') {
            "None" { $flags = $flags -bor [System.Security.AccessControl.PropagationFlags]::None }
            "NoPropagateInherit" { $flags = $flags -bor [System.Security.AccessControl.PropagationFlags]::NoPropagateInherit }
            "InheritOnly" { $flags = $flags -bor [System.Security.AccessControl.PropagationFlags]::InheritOnly }
            default { throw "Valeur de PropagationFlags non valide : $_" }
        }
    }
    return $flags
}

# Lire le CSV
$permissions = Import-Csv -Path $csvPath -Delimiter ";"

foreach ($permission in $permissions) {
    $path = $permission.'Path'
    $identity = $permission.'IdentityReference'
    $rightsString = $permission.'FileSystemRights'
    $controlTypeString = $permission.'AccessControlType'
    $inheritanceFlagsString = $permission.'InheritanceFlags'
    $propagationFlagsString = $permission.'PropagationFlags'
    $isInherited = $permission.'IsInherited'
    
    try {
        # Mapper les valeurs de FileSystemRights, InheritanceFlags et PropagationFlags
        $rights = Get-FileSystemRights -rightsString $rightsString
        $inheritanceFlags = Get-InheritanceFlags -flagsString $inheritanceFlagsString
        $propagationFlags = Get-PropagationFlags -flagsString $propagationFlagsString
        $controlType = [Enum]::Parse([System.Security.AccessControl.AccessControlType], $controlTypeString)
        
        # Récupérer les ACL actuelles du dossier
        $acl = Get-Acl -Path $path
        
        # Créer une nouvelle règle d'accès
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $rights, $inheritanceFlags, $propagationFlags, $controlType)
        
        # Ajouter la règle d'accès aux ACL
        $acl.SetAccessRule($accessRule)

        # Appliquer les nouvelles ACL au dossier
        Set-Acl -Path $path -AclObject $acl

        Write-Output "Les permissions pour $identity ont été appliquées au dossier $path"
    } catch {
        Write-Output "Erreur lors de l'application des permissions pour $identity au dossier $path : $_"
    }
}

Write-Output "Importation des permissions terminée."