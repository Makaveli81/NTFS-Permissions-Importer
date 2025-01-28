# Importer le module ActiveDirectory (assurez-vous que RSAT est installé)
Import-Module ActiveDirectory

# Définir le dossier d'exportation
$ExportPath = "C:\Export"
if (-not (Test-Path -Path $ExportPath)) {
    try {
        New-Item -ItemType Directory -Path $ExportPath -ErrorAction Stop
        Write-Host "Dossier d'exportation créé : $ExportPath"
    } catch {
        Write-Error "Impossible de créer le dossier d'exportation : $_"
        exit
    }
}

# Exporter les unités d'organisation (OU)
try {
    Get-ADOrganizationalUnit -Filter * | 
        Select-Object Name, DistinguishedName |
        Export-Csv -Path "$ExportPath\OUs.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    Write-Host "Exportation des OU terminée : $ExportPath\OUs.csv"
} catch {
    Write-Error "Erreur lors de l'exportation des OU : $_"
}

# Exporter les utilisateurs
try {
    Get-ADUser -Filter * -Property * | 
        Select-Object Name, SamAccountName, UserPrincipalName, EmailAddress, DistinguishedName |
        Export-Csv -Path "$ExportPath\Users.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    Write-Host "Exportation des utilisateurs terminée : $ExportPath\Users.csv"
} catch {
    Write-Error "Erreur lors de l'exportation des utilisateurs : $_"
}

# Exporter les groupes
try {
    Get-ADGroup -Filter * -Property * | 
        Select-Object Name, SamAccountName, GroupCategory, GroupScope, DistinguishedName |
        Export-Csv -Path "$ExportPath\Groups.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    Write-Host "Exportation des groupes terminée : $ExportPath\Groups.csv"
} catch {
    Write-Error "Erreur lors de l'exportation des groupes : $_"
}

# Exporter les membres des groupes
try {
    Get-ADGroup -Filter * | ForEach-Object {
        $group = $_
        Get-ADGroupMember -Identity $group | 
            Select-Object @{Name="GroupName";Expression={$group.Name}}, Name, SamAccountName, DistinguishedName
    } | Export-Csv -Path "$ExportPath\GroupMembers.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    Write-Host "Exportation des membres des groupes terminée : $ExportPath\GroupMembers.csv"
} catch {
    Write-Error "Erreur lors de l'exportation des membres des groupes : $_"
}

# Définir le chemin de l'arborescence de dossiers
$RootDirectory = "C:\Shares\DATA"

# Vérifier si le dossier racine existe
if (-not (Test-Path -Path $RootDirectory)) {
    Write-Error "Le dossier spécifié n'existe pas : $RootDirectory"
    exit
}

# Définir le chemin du dossier à analyser
$FolderPath = "C:\Shares\DATA\"

# Chemin du fichier CSV d'export
$ExportFile = "C:\Export\permissions_list.csv"

# Créer une liste pour stocker les résultats
$Results = @()

# Récupérer tous les dossiers et sous-dossiers
$Folders = Get-ChildItem -Path $FolderPath -Recurse -Directory

# Inclure également le dossier racine
$Folders = $Folders + (Get-Item -Path $FolderPath)

# Parcourir chaque dossier
foreach ($Folder in $Folders) {
    # Récupérer les ACL (permissions) du dossier
    $ACL = Get-Acl -Path $Folder.FullName

    # Extraire les informations et les formater
    $ACL.Access | ForEach-Object {
        $Results += [PSCustomObject]@{
            Path                   = $Folder.FullName
            IdentityReference      = $_.IdentityReference
            FileSystemRights       = $_.FileSystemRights
            AccessControlType      = $_.AccessControlType
            InheritanceFlags       = $_.InheritanceFlags
            PropagationFlags       = $_.PropagationFlags
            IsInherited            = $_.IsInherited
        }
    }
}

# Exporter les résultats vers un fichier CSV
$Results | Export-Csv -Path $ExportFile -NoTypeInformation -Encoding UTF8 -Delimiter ";"

Write-Host "Les permissions NTFS ont été exportées dans $ExportFile"

# Définir le chemin de l'arborescence de dossiers et le fichier CSV de sortie
$rootDirectory = "C:\Shares\DATA"
$outputFile = "C:\Export\directories_list.csv"

# Récupérer les noms des dossiers
$directories = Get-ChildItem -Path $rootDirectory -Recurse -Directory

# Créer un tableau d'objets avec les noms des dossiers
$directoryList = $directories | ForEach-Object {
    [PSCustomObject]@{
        "Directory Name" = $_.FullName
    }
}

# Exporter les noms des dossiers dans un fichier CSV
$directoryList | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Output "Les noms des dossiers ont été écrits dans $outputFile"


Write-Host "Toutes les exportations sont terminées. Les fichiers sont dans le dossier : $ExportPath"
