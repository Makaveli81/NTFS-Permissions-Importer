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
            default { throw "Valeur de FileSystemRights non valide : $_" }
        }
    }
    return $rights
}

# Lire le CSV
$permissions = Import-Csv -Path $csvPath

foreach ($permission in $permissions) {
    $directory = $permission.'Directory Name'
    $identity = $permission.'Identity Reference'
    $rightsString = $permission.'File System Rights'
    $controlTypeString = $permission.'Access Control Type'
    
    try {
        # Mapper les valeurs de FileSystemRights
        $rights = Get-FileSystemRights -rightsString $rightsString
        $controlType = [Enum]::Parse([System.Security.AccessControl.AccessControlType], $controlTypeString)
        
        # Récupérer les ACL actuelles du dossier
        $acl = Get-Acl -Path $directory
        
        # Créer une nouvelle règle d'accès
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $rights, $controlType)
        
        # Ajouter la règle d'accès aux ACL
        $acl.SetAccessRule($accessRule)
        
        # Appliquer les nouvelles ACL au dossier
        Set-Acl -Path $directory -AclObject $acl

        Write-Output "Les permissions pour $identity ont été appliquées au dossier $directory"
    } catch {
        Write-Output "Erreur lors de l'application des permissions pour $identity au dossier $directory : $_"
    }
}