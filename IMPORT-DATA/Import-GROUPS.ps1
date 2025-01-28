# Chemin vers le fichier CSV
$csvPath = "C:\Export\Groups.csv"

# Importer le fichier CSV
$groups = Import-Csv -Path $csvPath -Delimiter ";"

# Fonction pour extraire l'OU du DN complet
function Get-OUFromDN($dn) {
    # Diviser le DN au niveau de la première virgule
    $parts = $dn -split ",", 2
    if ($parts.Length -gt 1) {
        # Retourner la partie de l'OU
        return $parts[1]
    } else {
        return $null
    }
}

# Parcourir chaque ligne du CSV et créer des groupes AD
foreach ($group in $groups) {
    # Extraire les informations du groupe
    $name = $group.Name
    $samAccountName = $group.SamAccountName
    $groupCategory = $group.GroupCategory
    $groupScope = $group.GroupScope
    $distinguishedName = $group.DistinguishedName

    # Extraire l'OU du DN
    $ouPath = Get-OUFromDN -dn $distinguishedName

    # Vérifier si l'OU existe
    $ouExists = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue
    if ($ouExists) {
        # Créer le groupe AD
        New-ADGroup -Name $name -SamAccountName $samAccountName -GroupCategory $groupCategory -GroupScope $groupScope -Path $ouPath
        Write-Output "Groupe $name créé avec succès."
    } else {
        Write-Output "Erreur: L'OU spécifiée n'existe pas pour le groupe $name (OU: $ouPath)."
    }
}

Write-Output "Tous les groupes ont été traités."