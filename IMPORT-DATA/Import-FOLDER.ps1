# Définir les chemins des fichiers CSV
$directoriesCsv = "C:\Export\directories_list.csv"
$permissionsCsv = "C:\Export\permissions_list.csv"

# Lire les dossiers à partir du CSV
$directories = Import-Csv -Path $directoriesCsv

# Lire les permissions à partir du CSV
$permissions = Import-Csv -Path $permissionsCsv

# Créer les dossiers
foreach ($directory in $directories) {
    if (-not (Test-Path -Path $directory."Directory Name")) {
        New-Item -Path $directory."Directory Name" -ItemType Directory
        Write-Output "Dossier créé : $($directory.'Directory Name')"
    }
}
