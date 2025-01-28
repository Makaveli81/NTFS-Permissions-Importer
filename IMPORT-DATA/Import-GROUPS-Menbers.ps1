# Chemin vers le fichier CSV
$csvPath = "C:\Export\GroupMembers.csv"

# Importer le fichier CSV
$entries = Import-Csv -Path $csvPath -Delimiter ";"

# Parcourir chaque ligne du CSV et ajouter l'utilisateur aux groupes AD
foreach ($entry in $entries) {
    # Extraire les informations du groupe et de l'utilisateur
    $groupName = $entry.GroupName
    $userSamAccountName = $entry.SamAccountName

    # Ajouter l'utilisateur au groupe AD
    try {
        Add-ADGroupMember -Identity $groupName -Members $userSamAccountName
        Write-Output "Utilisateur $userSamAccountName ajouté au groupe $groupName avec succès."
    } catch {
        Write-Output "Erreur lors de l'ajout de l'utilisateur $userSamAccountName au groupe $groupName : $_"
    }
}

Write-Output "Tous les utilisateurs ont été ajoutés aux groupes."