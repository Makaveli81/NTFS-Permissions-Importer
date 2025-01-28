$CSVFile = "C:\Export\Users.csv"

# Importer les utilisateurs à partir du fichier CSV
$users = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($Utilisateur in $users) {
    if ($null -ne $Utilisateur.Name -and $null -ne $Utilisateur.SamAccountName -and $null -ne $Utilisateur.UserPrincipalName -and $null -ne $Utilisateur.DistinguishedName) {
        $UtilisateurNomComplet = $Utilisateur.Name
        $UtilisateurLogin = $Utilisateur.SamAccountName
        $UtilisateurUPN = $Utilisateur.UserPrincipalName
        $UtilisateurEmail = if ($Utilisateur.EmailAddress -ne "") { $Utilisateur.EmailAddress } else { "$UtilisateurLogin@crm.local" }
        $UtilisateurDN = $Utilisateur.DistinguishedName

        # Vérifier que l'OU existe
        $OUPath = ($UtilisateurDN -split ",", 2)[1] # Extraire le chemin de l'OU du DistinguishedName
        try {
            Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction Stop
            $OUExists = $true
        } catch {
            $OUExists = $false
            Write-Warning "Le chemin DN $OUPath n'existe pas dans l'AD"
        }

        if ($OUExists) {
            # Vérifier la présence de l'utilisateur dans l'AD
            if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
                Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
            } else {
                New-ADUser -Name $UtilisateurNomComplet `
                            -SamAccountName $UtilisateurLogin `
                            -UserPrincipalName $UtilisateurUPN `
                            -EmailAddress $UtilisateurEmail `
                            -Path $OUPath `
                            -AccountPassword (ConvertTo-SecureString "ChangeMeOrScriptMe" -AsPlainText -Force) `
                            -ChangePasswordAtLogon $true `
                            -Enabled $true

                Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNomComplet)"
            }
        }
    } else {
        Write-Warning "L'utilisateur avec les données suivantes est incomplet : $($Utilisateur | ConvertTo-Json)"
    }
}