# Chemin vers le fichier CSV contenant les membres des groupes
$csvPath = "C:\Export\GroupMembers.csv"

# Vérifier si le fichier CSV existe
if (-not (Test-Path -Path $csvPath)) {
    Write-Error "Le fichier CSV spécifié n'existe pas : $csvPath"
    exit
}

# Importer les données du fichier CSV
$entries = Import-Csv -Path $csvPath -Delimiter ";"

# Parcourir chaque ligne du CSV et ajouter les utilisateurs aux groupes AD
foreach ($entry in $entries) {
    try {
        # Extraire les informations du groupe et de l'utilisateur
        $groupName = $entry.GroupName
        $userSamAccountName = $entry.SamAccountName

        # Vérifier si le groupe existe
        $groupExists = Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue
        if (-not $groupExists) {
            Write-Warning "Le groupe '$groupName' n'existe pas. Utilisateur '$userSamAccountName' non ajouté."
            continue
        }

        # Vérifier si l'utilisateur existe
        $userExists = Get-ADUser -Filter "SamAccountName -eq '$userSamAccountName'" -ErrorAction SilentlyContinue
        if (-not $userExists) {
            Write-Warning "L'utilisateur '$userSamAccountName' n'existe pas. Impossible de l'ajouter au groupe '$groupName'."
            continue
        }

        # Ajouter l'utilisateur au groupe
        Add-ADGroupMember -Identity $groupName -Members $userSamAccountName
        Write-Host "Utilisateur '$userSamAccountName' ajouté au groupe '$groupName' avec succès."
    } catch {
        Write-Error "Erreur lors de l'ajout de l'utilisateur '$userSamAccountName' au groupe '$groupName' : $_"
    }
}

Write-Host "Tous les membres des groupes ont été traités."
