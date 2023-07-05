Import-Module ActiveDirectory

$ADUsers = Import-Csv C:\powershell\PFUsers.csv -Delimiter ";"

$UPN = "PoliForma.local"

foreach($User in $ADUsers){
    $firstname = $User.firstname # Madelief
    $lastname = $User.lastname # Smets
    $username = $User.username # Mad_Sme
    $password = $User.password # Mad&Sme
    $initials = $User.initials #

    $description = $User.description # Directeur
    $office = $User.office # B02
    $telephone = $User.telephone # 4101
    $profilePath = "\\PFSV1\UserProfiles\" + "$username"
    $homeFolder = "\\PFSV1\UserFolders\" + "$username"

    $jobtitle = $User.jobtitle # Directeur
    $department = $User.department # Directie

    $manager = $User.manager #

    if($User.OU -eq "Fabricage"){
        $OU = $User.ou + ",OU=Productie"
    }
    else{
        $OU = $User.ou #Directie
    }

    if(Get-ADUser -F {SamAccountName -eq $username}) {
        Write-Warning "User account with $username exists in AD"
    }
    else{
        New-ADUser `
            -Name "$firstname $lastname" `
            -GivenName "$firstname" `
            -Surname "$lastname" `
            -SamAccountName "$username" `
            -UserPrincipalName "$username@$UPN" `
            -Initials $initials `
            -DisplayName "$lastname, $firstname" `
            -Enabled $true `
            -PasswordNeverExpires $true `
            -Description "$description" `
            -Office "$office" `
            -OfficePhone "$telephone" `
            -AccountExpirationDate "2026/08/02T00:00:00.0000000" `
            -ProfilePath $profilePath `
            -HomeDrive "Z:" `
            -HomeDirectory "$homeFolder" `
            -LogonWorkstations "PFWS1"`
            -Title $jobtitle `
            -Department $department `
            -Company "PoliForma BV" `
            -Manager "$manager" `
            -Path "OU=$OU,OU=PFAfdelingen,DC=PoliForma,DC=local" `
            -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force)
        Write-Host "The user $username is created." -ForegroundColor Cyan
        
        [byte[]]$hours = @(0,0,0,128,255,1,128,255,1,128,255,1,128,255,1,128,255,1,0,0,0)
        set-aduser -identity $username -replace @{logonhours = $hours}
    }
}

Read-Host -Prompt "Press Enter to exit"