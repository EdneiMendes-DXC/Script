

function AddStatusText {
    param( 
        [Parameter(Mandatory = $true)]
        [string]$sText,
        [Parameter(Mandatory = $false)]
        [System.Drawing.Color]$color = 'black'

    )
    
    $txtStatus.SelectionStart = $txtStatus.TextLength
    $txtStatus.SelectionLength = 0
    $txtStatus.SelectionColor = 'black'
    $txtStatus.AppendText([environment]::NewLine + "[" + (Get-Date).ToString("dd/MM/yyyy HH:mm:ss") + "] ")
    $txtStatus.SelectionStart = $txtStatus.TextLength
    $txtStatus.SelectionColor = $color
    $txtStatus.AppendText("$sText")
    $txtStatus.ScrollToCaret()


}

function Move_OU {
    param (
        [string[]]$sHostName
    )
    
    Write-Host 'Starting Move OU Windows_10 ' $sHostName
    AddStatusText "$($sHostName): Starting Move OU Windows_10" DarkBlue
    
    try {

        if ($null -eq (Get-Module ActiveDirectory)) {
            AddStatusText "----- Importing ActiveDirectory Modules, please wait -----"
            Import-Module ActiveDirectory -ErrorAction Stop
        }

        if ($null -eq $AD_Cred) {
            AddStatusText "----- Starting AD Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }

        $aHost = @(Get-ADComputer -Identity "$sHostName" -Server "sa.kof.ccf" -Credential $AD_Cred)

        if ($aHost.Count -eq 1) {

            if ($aHost.DistinguishedName -imatch "OU=Windows_10,OU=Computers,OU=BRASIL,DC=sa,DC=kof,DC=ccf") {
                AddStatusText "$($sHostName): Already in OU Windows_10" DarkGreen
                Write-Host $sHostName ": Already in OU Windows_10"
            }
            else { 
                AddStatusText "$($sHostName): Not in OU Windows_10, moving..."
                Write-Host $sHostName ": Not in OU Windows_10, moving..."
                Move-ADObject -Identity $aHost.ObjectGUID -TargetPath "OU=Windows_10,OU=Computers,OU=BRASIL,DC=sa,DC=kof,DC=ccf" -Server "sa.kof.ccf" -Credential $AD_Cred
                Write-Host $sHostName ": Successfully moved to OU Windows_10"
                AddStatusText "$($sHostName): Successfully moved to OU Windows_10" DarkGreen
            } 
        }
        else {
            AddStatusText "$($sHostName): Not found on Acitive Directory." Red
        }
        
    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch "The specified module 'ActiveDirectory' was not loaded because no valid module file was found") { 
            Write-Host 'Acitive Directory Module not found' �ForegroundColor Red
            AddStatusText "----- Acitive Directory Module not installed ------" Red
        }
        else {
            $_
            AddStatusText "$($sHostName): Error: $($_)" Red
        }

    }    
    finally {
        AddStatusText "$($sHostName): End Move OU Windows_10" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }

}

function despliegue_sccm {
    param (
        [string[]]$sHostName
    )


    AddStatusText "$($sHostName): Starting Add despliegue_sccm" DarkBlue
    if ($null -eq (Get-Module Az.Resources)) { 
        AddStatusText "----- Starting Azure Authentication -----"
        Connect-AzAccount -Tenant '7094d542-3815-4c82-b1d5-6917d0443cf4' -Force
    }
    Write-Host 'Executar despliegue_sccm hostname' $sHostName
   
    try {
        if ($null -eq (Get-Module Az.Resources)) {
            AddStatusText "----- Importing Azure Modules, please wait some minutes -----"
            Import-Module Az.Resources
            Import-Module Az.Accounts
            #AddStatusText "----- Starting Azure Authentication -----"
            #Connect-AzAccount
        }
    
        $Token = Get-AzAccessToken -ResourceTypeName MSGraph
        $access_token = $Token.Token
        $graph = "https://graph.microsoft.com/v1.0/devices?`$filter=displayName eq '$($sHostName)' and trustType eq 'ServerAd'&`$count=true&ConsistencyLevel=eventual"
        $api = Invoke-RestMethod -Headers @{Authorization = "Bearer $($access_token)" } -Uri $graph -Method Get
        #$api.value | Select-Object DisplayName, ID

        if ($api.value.Count -eq 1) { 

            $api.value | Select-Object DisplayName, ID
            AddStatusText "$($sHostName): Found on Azure. Object ID: $($api.value.ID)" DarkGreen
    
            Add-AzADGroupMember -MemberObjectId $api.value.id -TargetGroupDisplayName "despliegue_sccm"
            $aAZGrupoDespliegue = @(Get-AzADGroupMember -GroupDisplayName "despliegue_sccm" | where { ( $_.DisplayName -eq $($sHostName) ) })
            if ($aAZGrupoDespliegue.Count -eq 1) { 
                Write-Host "ADD despliegue_sccm: Success" -ForegroundColor Green
                AddStatusText "$($sHostName): ADD despliegue_sccm: Success" DarkGreen
            } 
            else { 
                Write-Host "ADD despliegue_sccm: Error" -ForegroundColor Red
                AddStatusText "$($sHostName): ADD despliegue_sccm: Error" Red
            }
        }
        else {
            AddStatusText "$($sHostName): Hostname not found on Azure AD" Red
        }

    }
    catch {
        Write-host "Error" �ForegroundColor Red
        AddStatusText "$($sHostName): Error: $($_)" Red
        $_
    }      
    finally {
        AddStatusText "$($sHostName): End Add despliegue_sccm" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function Eliminar_PIN {
    param (
        [string[]]$sUserID
    )

    AddStatusText "$($sUserID): Starting Add user on 'Grupo Intune Eliminar PIN'" DarkBlue
    if ($null -eq (Get-Module Az.Resources)) { 
        AddStatusText "----- Starting Azure Authentication -----"
        Connect-AzAccount -Tenant '7094d542-3815-4c82-b1d5-6917d0443cf4' -Force
        }
    Write-Host 'Executar Add user on Eliminar PIN' $sUserID
    
    try {
        if ($null -eq (Get-Module Az.Resources)) {
            AddStatusText "----- Importing Azure Modules, please wait some minutes -----"
            Import-Module Az.Resources
            Import-Module Az.Accounts           
        }
    
        $Token = Get-AzAccessToken -ResourceTypeName MSGraph
        $access_token = $Token.Token
        $graph = "https://graph.microsoft.com/v1.0/users?`$filter=onPremisesSamAccountName eq '$($sUserID)'&`$count=true&ConsistencyLevel=eventual"
        
        $apiUser = Invoke-RestMethod -Headers @{Authorization = "Bearer $($access_token)" } -Uri $graph -Method Get

        if ($apiUser.value.Count -eq 1) { 

            $apiUser.value | Select-Object userPrincipalName, ID
            AddStatusText "$($sUserID): Found on Azure. Object ID: $($apiUser.value.ID)" DarkGreen
            AddStatusText "$($sUserID): Finding if user already on 'Grupo Intune Eliminar PIN'" Black

            $Token = Get-AzAccessToken -ResourceTypeName MSGraph
            $access_token = $Token.Token        
            $graph = "https://graph.microsoft.com/v1.0/groups/{32f4b3c9-ff39-4128-92d9-e2e0afc8e60d}/members?`$filter=onPremisesSamAccountName eq '$($sUserID)'&`$count=true&ConsistencyLevel=eventual"
            $api = Invoke-RestMethod -Headers @{Authorization = "Bearer $($access_token)" } -Uri $graph -Method Get
        
            if ($api.value.Count -eq 1) { 
                Write-Host "User already on Grupo Intune Eliminar PIN" -ForegroundColor Green
                AddStatusText "$($sUserID): User already on 'Grupo Intune Eliminar PIN'" DarkGreen
            }
            else{
        
                AddStatusText "$($sUserID): User not on 'Grupo Intune Eliminar PIN'. Adding..." DarkGreen
                Add-AzADGroupMember -MemberObjectId $apiUser.value.id -TargetGroupDisplayName "Grupo Intune Eliminar PIN"
                AddStatusText "$($sUserID): Successfully added user on 'Grupo Intune Eliminar PIN'" DarkGreen
             }
        }
        else {
            AddStatusText "$($sUserID): User not found on Azure AD" Red
        }
    }
    catch {
        Write-host "Error" �ForegroundColor Red
        AddStatusText "$($sUserID): Error: $($_)" Red
        $_
    }      
    finally {
        AddStatusText "$($sUserID): End Add 'Grupo Intune Eliminar PIN'" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function GU_KOF_INTUNE {
    param (
        [string[]]$sUserID
    )
    Write-Host 'Executar GU-KOF-INTUNE ID' $sUserID
    AddStatusText "$($sUserID): Starting Add GU-KOF-INTUNE" DarkBlue
   
    try {

        if ($null -eq (Get-Module ActiveDirectory)) {
            AddStatusText "----- Importing ActiveDirectory Modules, please wait -----"
            Import-Module ActiveDirectory -ErrorAction Stop
        }

        if ($null -eq $AD_Cred) {
            AddStatusText "----- Starting AD Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }

        #Get-ADUser -Identity  "$sUserID" -Server "sa.kof.ccf" -Credential $AD_Cred | Add-ADPrincipalGroupMembership -MemberOf "CN=GU-KOF-INTUNE,OU=Grupos Bitlocker-Intune,OU=Gpos de Administradores,DC=kof,DC=ccf" -Server "kof.ccf" -Credential $AD_Cred
        $User = $null
        $User  = Get-ADUser -Identity  "$sUserID" -Server "sa.kof.ccf" -Credential $AD_Cred
        $Group = Get-ADGroup -Identity "CN=GU-KOF-INTUNE,OU=Grupos Bitlocker-Intune,OU=Gpos de Administradores,DC=kof,DC=ccf" -Server "kof.ccf" -Credential $AD_Cred
        Add-ADGroupMember -Identity $Group -Members $User -Server "kof.ccf" -Credential $AD_Cred
        Write-Host "ADD GU-KOF-INTUNE: Success" -ForegroundColor Green
        AddStatusText "$($sUserID): ADD GU-KOF-INTUNE: Success" DarkGreen

    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch "The specified module 'ActiveDirectory' was not loaded because no valid module file was found") { 
            Write-Host ' Active Directory Module not found' �ForegroundColor Red
            AddStatusText "-----  Active Directory Module not installed ------" Red
        }
        else {
            $_
            AddStatusText "$($sUserID): Error: $($_)" Red
        }
    }    
    finally {
        AddStatusText "$($sUserID): End Add GU-KOF-INTUN" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function SCCM_INTUNE {
    param (
        [string[]]$sHostName
    )
    Write-Host 'Executar SCCM_INTUNE hostname' $sHostName
    AddStatusText "$($sHostName): Starting Add SCCM_INTUNE collection" DarkBlue

    try {
        if ($null -eq (Get-Module ConfigurationManager)) {
            AddStatusText("----- Importing SCCM Modules, please wait -----")
            Set-Location ".\BIN"# -ErrorAction SilentlyContinue
            Import-Module .\ConfigurationManager.psd1 -ErrorAction Stop
        }
    
        $SiteCode = "AX0"
        $ProviderMachineName = "kofmxqrcmsit.na.kof.ccf"
    
        if ($null -eq $AD_Cred) {
            AddStatusText "----- Starting SCCM Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }
    
        if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
            AddStatusText "----- Connecting to SCCM -----"
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName -Description "Primary site" -Credential $AD_Cred
        }
    
        Set-Location "$($SiteCode):"

        AddStatusText "$($sHostName): Looking for device on SCCM..."
    
        $CMResourceId = @(Get-CMDevice -Name "$sHostName" | Select-Object ResourceId)
        if ($CMResourceId.Count -ge 1) {
            AddStatusText "$($sHostName): Founded on SCCM" DarkGreen

            $aSCCM = @(Get-CMDevice -CollectionName "SCCM_INTUNE" | Select-Object Name | where { ( $_.Name -eq $("$sHostName")) })
            if ($aSCCM.Count -ge 1) {
                Write-Host "Host $($sHostName) is on SCCM_INTUNE Collection" -ForegroundColor Green 
                AddStatusText "$($sHostName): is on SCCM_INTUNE Collection" DarkGreen
            }
            else { 
                Write-Host "Host $($sHostName) is not on SCCM_INTUNE Collection" -ForegroundColor Red 
                AddStatusText "$($sHostName): is NOT on SCCM_INTUNE Collection" Red
            
                foreach ($ConfigMgrDevice in $CMResourceId) {
                    AddStatusText "$($sHostName): Adding to collection. ResourceID: $($ConfigMgrDevice.ResourceID)" DarkGreen
                    Get-CMCollection -Name "SCCM_INTUNE" | Add-CMDeviceCollectionDirectMembershipRule -ResourceId $ConfigMgrDevice.ResourceId
                    AddStatusText "$($sHostName): added to SCCM_INTUNE Collection" DarkGreen
                }

            }
   
        }
        else {
            AddStatusText "$($sHostName): Devide not found on SCCM" Red
        }
    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch "The specified module '.\ConfigurationManager.psd1' was not loaded because no valid module file was found ") { 
            Write-Host 'SCCM Module not found' �ForegroundColor Red
            AddStatusText "----- SCCM Modules not installed ------" Red
        }
        else {
            $_
            AddStatusText "$($sHostName): Error: $($_)" Red
        }
    }

    finally {
        AddStatusText "$($sHostName): End Add SCCM_INTUNE collection" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function Delete_AD {
    param (
        [string[]]$sHostName
    )

    Write-Host 'Executar Delete_AD hostname' $sHostName  
    AddStatusText "$($sHostName): Starting Delete host from AD" DarkBlue
   
    try {

        if ($null -eq (Get-Module ActiveDirectory)) {
            AddStatusText "----- Importing ActiveDirectory Modules, please wait -----"
            Import-Module ActiveDirectory -ErrorAction Stop
        }

        if ($null -eq $AD_Cred){
            AddStatusText "----- Starting AD Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }

        $aADComputer = @(Get-ADComputer -Identity "$sHostName" -Server "sa.kof.ccf" -Credential $AD_Cred)
        if ($aADComputer.Count -eq 1) {
            AddStatusText "$($sHostName): Founded on AD. Deleting objec" DarkGreen
            #Get-ADComputer -Identity "$sHostName" -Server "sa.kof.ccf" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false
            #AddStatusText "$($sHostName): Object successfully deleted from AD" DarkGreen
			Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOTOCAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOVUPAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARCIMAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOPEIAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOCTGAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCODUIAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOMDEAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOBGAAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARNORAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARCICAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFAROMCAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOIBGAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFMXDMADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOBAQAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARALCAD02.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARALCAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOOFCAD02.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOOFCAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOBGNAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOBGNAD02.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEMATAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEMARAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEBRMAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEMBSAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEBLAAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOCUCAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCONVAAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOVVCAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOBCAAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOSMTAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEDVLAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEVALAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARDREAD02.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRRBHADSA1.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVECOJAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVESCRAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEMAYAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRRBHADSA2.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVECCSAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVESFXAD01.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSANADSA1.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRJURADSA.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRJUNADSA02.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRITAADSA1.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRJURADSA2.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRJUNADSA1.sa.kof.ccf"
		    Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRJACADSA3.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRMGCADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRCGRADSA2.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRMCDADSA2.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEOFCAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRIPRADSA2.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRDIVADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRCTGADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRJZFADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEOFCAD02.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRCURADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRRFEADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRCVLADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRARAADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSRPADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRMARADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRBRUADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRCBEADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRMGAADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRCURADSA01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRITBADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSMCADSA4.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRPORADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRBOQADSA00.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSMCADSA2.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSMCADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOMNTAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSUMADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRATNADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOOFCAD03.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRPOAADSA2.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRPOAADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRBLUADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFMXDMADSA2.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEMBOAD02.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFBRSAAADSA1.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFUYMONAD02.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFUYMONAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"AZVMDCSAPROD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"AZVMDCSAPROD02.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFARPARAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFVEANTAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"KOFCOCALAD01.sa.kof.ccf"
            Get-ADComputer -Identity "$sHostName" -Credential $AD_Cred | Remove-ADComputer -Confirm:$false -server	"AZDCSAPRODSAP01.sa.kof.ccf"
            AddStatusText "$($sHostName): Object successfully deleted from AD" DarkGreen
        }
        else {
            Write-host "Not found or duplicate" �ForegroundColor Red
            AddStatusText "$($sHostName): Object not found or duplicate on AD" Red
        }  
    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch "The specified module 'ActiveDirectory' was not loaded because no valid module file was found ") { 
            Write-Host 'Acitive Directory Module not found' �ForegroundColor Red
            AddStatusText "----- Acitive Directory Module not installed ------" Red
        }
        else {
            $_
            AddStatusText "$($sHostName): Error: $($_)" Red
        }
    }
    finally {

        AddStatusText "$($sHostName): End Delete host from AD" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function Delete_Azure_AD {
    param (
        [string[]]$sHostName
    )



    AddStatusText "$($sHostName): Starting Delete host from Azure AD" DarkBlue
    if ($null -eq (Get-Module Az.Accounts)) { 
        AddStatusText "----- Starting Azure Authentication -----"
        Connect-AzAccount -Tenant '7094d542-3815-4c82-b1d5-6917d0443cf4' -Force
    }
    Write-Host 'Executar Delete Azure AD hostname' $sHostName
   
    try {
        if ($null -eq (Get-Module Az.Accounts)) {
            AddStatusText "----- Importing Azure Modules, please wait some minutes -----"
            Import-Module Az.Accounts
            #AddStatusText "----- Starting Azure Authentication -----"
            #Connect-AzAccount
        }

        Write-host "Retrieving " �NoNewline
        Write-host "Azure AD " �ForegroundColor Yellow �NoNewline
        Write-host "device record/s... " �NoNewline 
    
        $Token = Get-AzAccessToken -ResourceTypeName MSGraph
        $access_token = $Token.Token
        $graph = "https://graph.microsoft.com/v1.0/devices?`$filter=displayName eq '$($sHostName)' and trustType eq 'ServerAd'&`$count=true&ConsistencyLevel=eventual"
        $api = Invoke-RestMethod -Headers @{Authorization = "Bearer $($access_token)" } -Uri $graph -Method Get
        #$api.value | Select-Object DisplayName,ID,isManaged,trustType
    
        If ($api.value.Count -ge 1) {
            Write-Host "Success" �ForegroundColor Green
            AddStatusText "$($sHostName): founded on Azure AD" DarkGreen
            Foreach ($AzureADDevice in $api.value) {
                AddStatusText "$($sHostName): Deleting ObjectId: $($AzureADDevice.id) | DeviceId: $($AzureADDevice.deviceId)" DarkGreen
                Write-host "   Deleting Hostname: $($AzureADDevice.displayName) | ObjectId: $($AzureADDevice.id) | DeviceId: $($AzureADDevice.deviceId)... " �NoNewline
                $graph = "https://graph.microsoft.com/v1.0/devices/$($AzureADDevice.id)"
                $api = Invoke-RestMethod -Headers @{Authorization = "Bearer $($access_token)" } -Uri $graph -Method Delete
                Write-host "Success" �ForegroundColor Green              
                AddStatusText "$($sHostName): Object successfully deleted from Azure AD" DarkGreen
            }      
        }  
        Else {
            Write-host "Not found!" �ForegroundColor Red
            AddStatusText "$($sHostName): Object not found on Azure AD" Red
        }
    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch '(403) Forbidden') { 
            Write-Host '(403) Forbidden.' �ForegroundColor Red
            AddStatusText "$($sHostName): Error to delete. (403) Forbidden" Red
        }
        else {
            $_
            AddStatusText "$($sHostName): Error: $($_)" Red
        }
        
    }
    finally {
        AddStatusText "$($sHostName): End Delete host from Azure AD" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function Delete_SCCM {
    param (
        [string[]]$sHostName
    )
    Write-Host 'Executar Delete SCCM hostname' $sHostName
    AddStatusText "$($sHostName): Starting Delete host from SCCM" DarkBlue
    
    try {
        if ($null -eq (Get-Module ConfigurationManager)) {
            AddStatusText "----- Importing SCCM Modules, please wait -----"
            Set-Location ".\BIN"# -ErrorAction SilentlyContinue
            Import-Module .\ConfigurationManager.psd1 -ErrorAction Stop
        }
    
        $SiteCode = "AX0"
        $ProviderMachineName = "kofmxqrcmsit.na.kof.ccf"
    
        if ($null -eq $AD_Cred) {
            AddStatusText "----- Starting SCCM Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }
    
        if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
            AddStatusText "----- Connecting to SCCM -----"
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName -Description "Primary site" -Credential $AD_Cred
        }
    
        Set-Location "$($SiteCode):"

        AddStatusText "$($sHostName): Looking for device on SCCM..."

        Write-host "Retrieving " �NoNewline
        Write-host "SCCM " �ForegroundColor Yellow �NoNewline
        Write-host "device for $($sHostName)... "  �NoNewline       
        Set-Location ("$SiteCode" + ":") �ErrorAction Stop
        $ConfigMgrDevices = @(Get-CMDevice -Name "$sHostName")
        if ($ConfigMgrDevices.Count -ge 1) {
            AddStatusText "$($sHostName): Founded on SCCM" DarkGreen
            foreach ($ConfigMgrDevice in $ConfigMgrDevices) {
                Write-host "   Deleting Name: $($ConfigMgrDevice.Name) | ResourceID: $($ConfigMgrDevice.ResourceID) | SMSID: $($ConfigMgrDevice.SMSID)... " �NoNewline
                AddStatusText "$($sHostName): Deleting ResourceID: $($ConfigMgrDevice.ResourceID) | SMSID: $($ConfigMgrDevice.SMSID)" DarkGreen
                Remove-CMDevice �InputObject $ConfigMgrDevice �Force �ErrorAction Stop #-Verbose
            }
            $CMDevice = @(Get-CMDevice -Name "$sHostName")
            if ($CMDevice.Count -eq 1) { 
                Write-Host "Error removing host $($sHostName) from SCCM" -ForegroundColor Red
                AddStatusText "$($sHostName): Error removing device from SCCM" Red
            }
            else {
                Write-Host "Host $($sHostName) successfully removed from SCCM" -ForegroundColor Green
                AddStatusText "$($sHostName): Device successfully deleted from SCCMM" DarkGreen
            }
        }
        else { 
            Write-Host "Host $($sHostName) not found on SCCM" -ForegroundColor Green 
            AddStatusText "$($sHostName): Devide not found on SCCM" DarkGreen
        }
    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch "The specified module '.\ConfigurationManager.psd1' was not loaded because no valid module file was found ") { 
            Write-Host 'SCCM Module not found' �ForegroundColor Red
            AddStatusText "----- SCCM Modules not installed ------" Red
        }
        else {
            $_
            AddStatusText "$($sHostName): Error: $($_)" Red
        }
    }
    finally {
        AddStatusText "$($sHostName): End Delete host from SCCM" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }
}

function Move_OU_Apps {
    param (
        [string[]]$sHostName
    )
    
    Write-Host 'Starting Move OU Windows_10_Apps ' $sHostName
    AddStatusText "$($sHostName): Starting Move OU Windows_10_Apps" DarkBlue
    
    try {

        if ($null -eq (Get-Module ActiveDirectory)) {
            AddStatusText "----- Importing ActiveDirectory Modules, please wait -----"
            Import-Module ActiveDirectory -ErrorAction Stop
        }

        if ($null -eq $AD_Cred) {
            AddStatusText "----- Starting AD Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }

        $aHost = @(Get-ADComputer -Identity "$sHostName" -Server "sa.kof.ccf" -Credential $AD_Cred)

        if ($aHost.Count -eq 1) {

            if ($aHost.DistinguishedName -imatch "OU=Windows_10_Apps,OU=Computers,OU=BRASIL,DC=sa,DC=kof,DC=ccf") {
                AddStatusText "$($sHostName): Already in OU Windows_10_Apps" DarkGreen
                Write-Host $sHostName ": Already in OU Windows_10_Apps"
            }
            else { 
                AddStatusText "$($sHostName): Not in OU Windows_10_Apps, moving..."
                Write-Host $sHostName ": Not in OU Windows_10_Apps, moving..."
                Move-ADObject -Identity $aHost.ObjectGUID -TargetPath "OU=Windows_10_Apps,OU=Computers,OU=BRASIL,DC=sa,DC=kof,DC=ccf" -Server "sa.kof.ccf" -Credential $AD_Cred
                Write-Host $sHostName ": Successfully moved to OU Windows_10_Apps"
                AddStatusText "$($sHostName): Successfully moved to OU Windows_10_Apps" DarkGreen
            } 
        }
        else {
            AddStatusText "$($sHostName): Not found on Acitive Directory." Red
        }
        
    }
    catch {
        Write-host "Error! " �ForegroundColor Red -NoNewline
        if ($_ | Select-String -SimpleMatch "The specified module 'ActiveDirectory' was not loaded because no valid module file was found") { 
            Write-Host 'Acitive Directory Module not found' �ForegroundColor Red
            AddStatusText "----- Acitive Directory Module not installed ------" Red
        }
        else {
            $_
            AddStatusText "$($sHostName): Error: $($_)" Red
        }

    }    
    finally {
        AddStatusText "$($sHostName): End Move OU Windows_10_Apps" DarkBlue
        AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
    }

}

$okButton_Click = {
    $this.Enabled = $false
    $Hostname = $TextBoxHostName.Text
    $UserID = $TextBoxUserID.Text
    
    ForEach ($CheckedItem in $CheckedListBox.CheckedItems) {

        if ($CheckedItem -eq 'Move computer OU Windows_10') {
            if ($Hostname.Length -le 3 ) {
                Write-Host 'Invalid Hostname'
                AddStatusText($HostName + ' Invalid Hostname. Move computer OU Windows_10 aborted')
            }
            else {
                Move_OU -sHostName $Hostname 
            }

        }

        if ($CheckedItem -eq 'Add host group "despliegue_sccm"') {
            if ($Hostname.Length -le 3 ) {
                Write-Host 'Invalid Hostname'
                AddStatusText($HostName + ' Invalid Hostname. Add host group "despliegue_sccm" aborted')
            }
            else {
                despliegue_sccm -sHostName $Hostname 
            }

        }

        if ($CheckedItem -eq 'Add user group GU-KOF-INTUNE') {
            if ($UserID.Length -le 3 ) {
                Write-Host 'Invalid UserID'
                AddStatusText($UserID + ' Invalid UserID. Add user group GU-KOF-INTUNE aborted')
            }
            else {
                GU_KOF_INTUNE -sUserID $UserID
            }
        }

        if ($CheckedItem -eq 'Add user group Eliminar PIN') {
            if ($UserID.Length -le 3 ) {
                Write-Host 'Invalid UserID'
                AddStatusText($UserID + ' Invalid UserID. Add user group Eliminar PIN')
            }
            else {
                Eliminar_PIN -sUserID $UserID
            }
        }

        if ($CheckedItem -eq 'Add host collecttion SCCM_INTUNE') {
            if ($Hostname.Length -le 3 ) {
                Write-Host 'Invalid Hostname'
                AddStatusText($HostName + ' Invalid Hostname. Add host collecttion SCCM_INTUNE aborted')
            }
            else {
                SCCM_INTUNE -sHostName $Hostname
            }
        }
        if ($CheckedItem -eq 'Delete host from AD') {
            if ($Hostname.Length -le 3 ) {
                Write-Host 'Invalid Hostname'
                AddStatusText($HostName + ' Invalid Hostname. Delete host from AD aborted')
            }
            else {
                Delete_AD -sHostName $Hostname
            }
        }
        if ($CheckedItem -eq 'Delete host from SCCM') {
            if ($Hostname.Length -le 3 ) {
                Write-Host 'Invalid Hostname'
                AddStatusText($HostName + ' Invalid Hostname. Delete host from SCCM aborted')
            }
            else {
                Delete_SCCM -sHostName $Hostname
            }
        }
        if ($CheckedItem -eq 'Move computer OU Windows_10_Apps') {
            if ($Hostname.Length -le 3 ) {
                Write-Host 'Invalid Hostname'
                AddStatusText($HostName + ' Invalid Hostname. Move computer OU Windows_10_Apps aborted')
            }
            else {
                Move_OU_Apps -sHostName $Hostname 
            }

        }		
    }
    $this.Enabled = $true

}
$reportButton_Click = {
    
    $this.Enabled = $false
    Write-Host 'Starting Extract OU Computers Report'
    AddStatusText "Starting Extract OU Computers Report" DarkBlue
    try {
        if ($null -eq (Get-Module ActiveDirectory)) {
            AddStatusText "----- Importing ActiveDirectory Modules, please wait -----"
            Import-Module ActiveDirectory -ErrorAction Stop
        }

        if ($null -eq $AD_Cred) {
            AddStatusText "----- Starting AD Authentication -----"
            $Global:AD_Cred = Get-Credential -Message "Enter credentials for the KOF Domain (format: Domain\ID)" -UserName "sa.kof.ccf\"
        }
    }
        catch {
            Write-host "Error! " �ForegroundColor Red -NoNewline
            if ($_ | Select-String -SimpleMatch "The specified module 'ActiveDirectory' was not loaded because no valid module file was found") { 
                Write-Host 'Acitive Directory Module not found' �ForegroundColor Red
                AddStatusText "----- Acitive Directory Module not installed ------" Red
            }
            else {
                $_
                AddStatusText "$($sHostName): Error: $($_)" Red
            }
    
        }    
        finally {
            $FileName = "ALL-OUComputers-FemsaBR-$(get-date -f yyyy-MM-dd).csv"
            $OUComp = "CN=Computers,DC=sa,DC=kof,DC=ccf"
            $AccOUBR = Get-ADComputer -Filter * -SearchBase $OUComp -Properties DistinguishedName, Name, OperatingSystem, OperatingSystemServicePack, `
            lastLogonDate, LastLogonTimestamp, extensionAttribute1, PasswordLastSet, createTimeStamp, extensionAttribute1, whenChanged, userAccountControl, nTSecurityDescriptor |
        Select-Object Name, DistinguishedName, OperatingSystem, OperatingSystemServicePack, `
            @{name='Owner';`
              Expression={$_.nTSecurityDescriptor.Owner}}, `
            lastLogonDate, PasswordLastSet, createTimeStamp, Enabled, extensionAttribute1, whenChanged, userAccountControl |
        Sort LastLogonDate, PasswordLastSet
            $AccOUBR | Export-CSV -Path $Filename
            AddStatusText "End Extract OU Computers list" DarkBlue
            AddStatusText "-----------------------------------------------------------------------------------" DarkBlue
        }
    
    
        $this.Enabled = $true

}
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'Retrofit-form.designer.ps1')
$Form1.ShowDialog()