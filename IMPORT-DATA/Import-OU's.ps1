# Importer le module ActiveDirectory (nécessite les outils RSAT)
Import-Module ActiveDirectory

# Spécifiez le chemin du fichier CSV contenant les OU
$csvPath = "C:\Export\OUs.csv"

# Vérifier si le fichier CSV existe
if (-not (Test-Path -Path $csvPath)) {
    Write-Error "Le fichier CSV spécifié n'existe pas : $csvPath"
    exit
}

# Importer les données du fichier CSV
$ouData = Import-Csv -Path $csvPath -Delimiter ";"

# Parcourir chaque ligne du fichier CSV pour créer les OU
foreach ($ou in $ouData) {
    try {
        # Vérifier si l'OU existe déjà
        $ouExists = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$($ou.DistinguishedName)'" -ErrorAction SilentlyContinue

        if (-not $ouExists) {
            # Identifier le chemin parent (sans le nom de l'OU)
            $parentPath = ($ou.DistinguishedName -split ",", 2)[1]
            
            # Créer l'OU si elle n'existe pas
            New-ADOrganizationalUnit -Name $ou.Name -Path $parentPath
            Write-Host "L'unité d'organisation '$($ou.Name)' a été créée avec succès."
        } else {
            Write-Host "L'unité d'organisation '$($ou.Name)' existe déjà."
        }
    } catch {
        Write-Error "Erreur lors de la création de l'OU '$($ou.Name)' : $_"
    }
}

Write-Host "Importation des unités d'organisation terminée."
