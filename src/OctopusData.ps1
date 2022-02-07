function Get-OctopusData {
    param(
        $octopusUrl,
        $octopusApiKey,
        $space
    )
    $spaceId = $space.Id;
    $spaceName = $space.Name;

    $octopusData = @{
        octopusUrl    = $octopusUrl;
        octopusApiKey = $octopusApiKey;
        Space         = $space;
        SpaceId       = $spaceId;
        SpaceName     = $spaceName
    }
       
    # Write-OctopusSuccess "Getting Environments for '$spaceName' in $octopusUrl"
    # $octopusData.EnvironmentList = @(Get-OctopusEnvironmentList -octopusData $octopusData)
    
    # Write-OctopusSuccess "Getting Worker Pools for '$spaceName' in $octopusUrl"
    # $octopusData.WorkerPoolList = @(Get-OctopusWorkerPoolList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Tenant Tags for '$spaceName' in $octopusUrl"
    # $octopusData.TenantTagList = @(Get-OctopusTenantTagSetList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Tenants for '$spaceName' in $octopusUrl"
    # $octopusData.TenantList = @(Get-OctopusTenantList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Machine Policies for '$spaceName' in $OctopusUrl"
    # $octopusData.MachinePolicyList = @(Get-OctopusMachinePolicyList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Workers for '$spaceName' in $OctopusUrl"
    # $octopusData.WorkerList = @(Get-OctopusWorkerList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Targets for '$spaceName' in $OctopusUrl"
    # $octopusData.TargetList = @(Get-OctopusTargetList -octopusData $octopusData)

    Write-OctopusSuccess "Getting Step Templates for '$spaceName' in $octopusUrl"
    $octopusData.StepTemplates = @(Get-OctopusStepTemplateList -octopusData $octopusData)
    #$octopusData.CommunityActionTemplates = @(Get-OctopusCommunityActionTemplateList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Infrastructure Accounts for '$spaceName' in $octopusUrl"
    # $octopusData.InfrastructureAccounts = @(Get-OctopusInfrastructureAccountList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Library Variable Sets for '$spaceName' in $octopusUrl"
    # $octopusData.VariableSetList = @(Get-OctopusLibrarySetList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Lifecycles for '$spaceName' in $octopusUrl"
    # $octopusData.LifeCycleList = @(Get-OctopusLifeCycleList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Project Groups for '$spaceName' in $octopusUrl"
    # $octopusData.ProjectGroupList = @(Get-ProjectGroupList -octopusData $octopusData)
    
    Write-OctopusSuccess "Getting Projects for '$spaceName' in $octopusUrl"
    $octopusData.ProjectList = @(Get-OctopusProjectList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Feed List for '$spaceName' in $octopusUrl"
    # $octopusData.FeedList = @(Get-OctopusFeedList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Script Modules for '$spaceName' in $OctopusUrl"
    # $octopusData.ScriptModuleList = @(Get-OctopusScriptModuleList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Teams for '$spaceName' in $OctopusUrl"
    # $octopusData.TeamList = @(Get-OctopusTeamList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Users for '$spaceName' in $OctopusUrl"
    # $octopusData.UserList = @(Get-OctopusUserList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting User Roles for '$spaceName' in $OctopusUrl"
    # $octopusData.UserRoleList = @(Get-OctopusUserList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Packages for '$spaceName' in $OctopusUrl"
    # $octopusData.PackageList = @(Get-OctopusPackageList -octopusData $octopusData)

    # Write-OctopusSuccess "Getting Certificates for '$spaceName' in $OctopusUrl"
    # $octopusData.CertificateList = @(Get-OctopusCertificateList -octopusData $octopusData)

    $octopusData.ProjectRunbooks = @{}
    $octopusData.ProjectChannels = @{}
    $octopusData.ProjectProcesses = @{}
    $octopusData.ProjectRunbookProcesses = @{}
    $octopusData.ProjectVariableSets = @{}
    $octopusData.LibraryVariableSets = @{}

    return $octopusData
}