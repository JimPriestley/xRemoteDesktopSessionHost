Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(function Test-xRemoteDesktopSessionHostOsGe10)) { Throw "The minimum OS requirement was not met."}
Import-Module RemoteDesktop
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (    
        [parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [parameter(Mandatory)]
        [string] $SessionHost,
        [parameter(Mandatory)]
        [bool]   $GrantAdministrativePriviledge,
        [bool]   $AutoAssignUser,
        [string] $CollectionDescription,
        [string] $ConnectionBroker
    )
    Write-Verbose "Getting information about RDSH collection."
        $Collection = Get-RDSessionCollection -ErrorAction SilentlyContinue
        @{
        "CollectionName" = $Collection.CollectionName;
        "CollectionDescription" = $Collection.CollectionDescription
        "CollectionAlias" = $Collection.CollectionAlias
        "SessionHost" = $localhost
        "ConnectionBroker" = $ConnectionBroker
        "Size" = $Collection.Size
        "ResourceType" = $Collection.ResourceType
        "AutoAssignPersonalDesktop" = $Collection.AutoAssignPersonalDesktop
        "GrantAdministrativePrivilege" = $Collection.GrantAdministrativePrivilege
        "CollectionType" = $Collection.CollectionType
        }
}


######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource

{
    [CmdletBinding()]
    param
    (    
        [parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [parameter(Mandatory)]
        [string] $SessionHost,
        [parameter(Mandatory)]
        [bool]   $GrantAdministrativePriviledge,
        [bool]   $AutoAssignUser,
        [string] $CollectionDescription,
        [string] $ConnectionBroker
    )
    Write-Verbose "Creating a new RDSH collection."
    $PSBoundParameters.Add("PersonalUnmanaged", $true)

    if ($localhost -eq $ConnectionBroker) {
        New-RDSessionCollection @PSBoundParameters
        }
    else {
        $PSBoundParameters.Remove("Description")
        Add-RDSessionHost @PSBoundParameters
        }
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [parameter(Mandatory)]
        [string] $SessionHost,
        [parameter(Mandatory)]
        [bool]   $GrantAdministrativePriviledge,
        [bool]   $AutoAssignUser,
        [string] $CollectionDescription,
        [string] $ConnectionBroker
    )
    Write-Verbose "Checking for existance of RDSH collection."
    $sessionCollection = Get-TargetResource @PSBoundParameters

    if ($null -eq $sessionCollection)
    {
        Write-Verbose "RDSH collection does not exist!"
        return $false
    }

    if ($sessionCollection.CollectionType -ne "PersonalUnmanaged")
    {
        Write-Verbose "RDSH collection is not PersonalUnmanaged!"
        return $false    
    }

    if ($sessionCollection.GrantAdministrativePrivilege -ne $GrantAdministrativePriviledge)
    {
        Write-Verbose "RDSH collection GrantAdministrativePrivilege is not correct!"
        return $false    
    }

    if ($sessionCollection.AutoAssignUser -ne $AutoAssignUser)
    {
        Write-Verbose "RDSH collection AutoAssignUser is not correct!"
        return $false    
    }

    #default
    return $true
}


Export-ModuleMember -Function *-TargetResource

