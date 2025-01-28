# Vérifier si le fichier source existe
if (Test-Path "C:\Users\Administrateur\Documents\NTFS Permissions Report.html") {
    # Lire le contenu du fichier HTML
    $html = Get-Content -Path "C:\Users\Administrateur\Documents\NTFS Permissions Report.html" -Raw

    # Initialiser le tableau pour stocker les données
    $data = @()

    # Utiliser une expression régulière plus précise pour extraire les lignes de données
    $rows = [regex]::Matches($html, '<tr[^>]*>.*?</tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)

    foreach ($row in $rows) {
        # Extraire les valeurs des cellules TD
        $values = [regex]::Matches($row.Value, '(?<=<td[^>]*>)(.*?)(?=</td>)') | ForEach-Object { 
            $_.Value -replace '&amp;ensp;', '' -replace '&nbsp;', '' 
        }

        # Vérifier si nous avons le bon nombre de colonnes
        if ($values.Count -eq 13) {
            $obj = [PSCustomObject]@{
                'Path' = $values[0]
                'RelativePath' = $values[1]
                'Type' = $values[2]
                'Account' = $values[3]
                'Username' = $values[4]
                'Group' = $values[5]
                'AccessType' = $values[6]
                'Blank' = $values[7]
                'Permission' = $values[8]
                'Scope' = $values[9]
                'Inherited' = $values[10]
                'SID' = $values[11]
                'DetailedPermissions' = $values[12]
            }
            $data += $obj
        }
    }

    # Vérifier si nous avons des données à exporter
    if ($data.Count -gt 0) {
        # Corriger le chemin de sortie
        $outputPath = "C:\Users\Administrateur\Desktop\permissions_report.csv"
        
        # Exporter les données avec point-virgule comme délimiteur
        $data | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
        
        # Vérifier si le fichier a été créé
        if (Test-Path $outputPath) {
            Write-Host "Fichier CSV créé avec succès : $outputPath"
            Write-Host "Nombre d'entrées exportées : $($data.Count)"
        } else {
            Write-Host "Erreur : Le fichier n'a pas pu être créé"
        }
    } else {
        Write-Host "Aucune donnée n'a été trouvée à exporter"
    }
} else {
    Write-Host "Erreur : Le fichier source HTML n'existe pas"
}