function Test-xRemoteDesktopSessionHostOsRequirement
{
    return (Get-OsVersion) -ge (new-object 'Version' 6,2,9200,0)
}

function Test-xRemoteDesktopSessionHostOsGe10
{
    return (Get-OsVersion) -ge (new-object 'Version' 10,0,0,0)
}

function Get-OsVersion
{
    return [Environment]::OSVersion.Version 
}
Export-ModuleMember -Function @(
        'Test-xRemoteDesktopSessionHostOsRequirement'
)
