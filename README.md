
# Objectif des Scripts

Cette suite de scripts a été développée pour faciliter l'importation des données d'un serveur de production vers un environnement de test. L'objectif principal est d'analyser les permissions NTFS, ainsi que les objets Active Directory (OU, utilisateurs, groupes, etc.), dans un environnement sécurisé. Ces données peuvent ensuite être retravaillées, modifiées ou optimisées avant d'être réintégrées dans un environnement de production.

# Scripts d'Exportation et d'Importation pour Environnement Windows Serveur

Ce dépôt contient plusieurs scripts PowerShell utilisés dans un environnement hybride/test/production pour exporter et importer une arborescence de fichiers et des objets Active Directory.

## Structure du Dépôt

- `EXPORT-DATA/EXPORT-DATA.ps1` : Exporte les OU, utilisateurs, groupes, membres des groupes AD, noms des dossiers et permissions NTFS dans des fichiers CSV.
- `IMPORT-DATA/Import-FOLDER.ps1` : Importe et crée des dossiers à partir d'un fichier CSV.
- `IMPORT-DATA/Import-GROUPS-Menbers.ps1` : Importe et ajoute des membres aux groupes AD à partir d'un fichier CSV.
- `IMPORT-DATA/Import-GROUPS.ps1` : Importe et crée des groupes AD à partir d'un fichier CSV.
- `IMPORT-DATA/Import-NTFS.ps1` : Importe et applique des permissions NTFS aux dossiers à partir d'un fichier CSV.
- `IMPORT-DATA/Import-OU's.ps1` : Importe et crée des Unités Organisationnelles (OU) à partir d'un fichier CSV.
- `IMPORT-DATA/Import-USER's.ps1` : Importe et crée des utilisateurs AD à partir d'un fichier CSV.
- `TOOLS/HTML-to-CSV.ps1` : Convertit un fichier HTML en CSV pour l'analyse des droits NTFS.

## Utilisation

### Exportation

1. Exécutez `EXPORT-DATA/EXPORT-DATA-OK.ps1` ou `EXPORT-DATA/EXPORT-DATA.ps1` pour exporter les OU, utilisateurs, groupes, membres des groupes AD, noms des dossiers et permissions NTFS.

### Importation

1. Exécutez `IMPORT-DATA/Import-OU's.ps1` pour importer et créer les OU.
2. Exécutez `IMPORT-DATA/Import-USER's.ps1` pour importer et créer les utilisateurs.
3. Exécutez `IMPORT-DATA/Import-GROUPS.ps1` pour importer et créer les groupes.
4. Exécutez `IMPORT-DATA/Import-GROUPS-Menbers.ps1` pour importer et ajouter des membres aux groupes AD.
5. Exécutez `IMPORT-DATA/Import-FOLDER.ps1` pour importer et créer les dossiers.
6. Exécutez `IMPORT-DATA/Import-NTFS.ps1` pour importer et appliquer les permissions NTFS aux dossiers.

### Conversion HTML en CSV

1. Exécutez `TOOLS/HTML-to-CSV.ps1` pour convertir un fichier HTML en CSV pour l'analyse des droits NTFS.

## Prérequis

- PowerShell 5.1 ou supérieur
- Module Active Directory (`Install-Module -Name ActiveDirectory`)

## Avertissement

Ces scripts doivent être utilisés avec précaution dans un environnement de production. Il est recommandé de les tester dans un environnement de test avant de les déployer en production.

## Auteur

Makaveli81

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.