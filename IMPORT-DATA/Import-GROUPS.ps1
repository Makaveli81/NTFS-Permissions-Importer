# Chemin vers le fichier CSV contenant les groupes
$csvPath = "C:\Export\Groups.csv"

# Vérifier si le fichier CSV existe
if (-not (Test-Path -Path $csvPath)) {
    Write-Error "Le fichier CSV spécifié n'existe pas : $csvPath"
    exit
}

# Importer les données du fichier CSV
$groups = Import-Csv -Path $csvPath -Delimiter ";"

# Fonction pour extraire l'OU du DN complet
function Get-OUFromDN($dn) {
    try {
        # Diviser le DN au niveau de la première virgule
        $parts = $dn -split ",", 2
        if ($parts.Length -gt 1) {
            # Retourner la partie de l'OU
            return $parts[1]
        } else {
            return $null
        }
    } catch {
        Write-Error "Erreur lors de l'extraction de l'OU à partir du DN : $dn"
        return $null
    }
}

# Parcourir chaque ligne du CSV et créer les groupes AD
foreach ($group in $groups) {
    try {
        # Extraire les informations du groupe
        $name = $group.Name
        $samAccountName = $group.SamAccountName
        $groupCategory = $group.GroupCategory
        $groupScope = $group.GroupScope
        $distinguishedName = $group.DistinguishedName

        # Extraire le chemin de l'OU à partir du DN
        $ouPath = Get-OUFromDN -dn $distinguishedName

        if ($ouPath) {
            # Vérifier si l'OU existe
            $ouExists = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue

            if ($ouExists) {
                # Créer le groupe si l'OU existe
                New-ADGroup -Name $name `
                            -SamAccountName $samAccountName `
                            -GroupCategory $groupCategory `
                            -GroupScope $groupScope `
                            -Path $ouPath
                Write-Host "Groupe '$name' créé avec succès dans l'OU : $ouPath"
            } else {
                Write-Warning "L'OU spécifiée n'existe pas pour le groupe '$name' (OU : $ouPath)."
            }
        } else {
            Write-Warning "Impossible de déterminer l'OU pour le groupe '$name' (DN : $distinguishedName)."
        }
    } catch {
        Write-Error "Erreur lors de la création du groupe '$name' : $_"
    }
}

Write-Host "Traitement des groupes terminé."
