function Get-OctopusBaseApiInformation {
    param(
        $octopusData
    )

    return Get-OctopusApi -EndPoint "/api" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null 
}
function Get-OctopusSpaceList {
    param (
        $OctopusUrl,
        $OctopusApiKey
    )

    return Get-OctopusApiItemList -EndPoint "spaces?skip=0&take=1000" -ApiKey $OctopusApiKey -OctopusUrl $OctopusUrl -SpaceId $null
}

Function Get-OctopusProjectList {
    param (        
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "Projects?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusEnvironmentList {
    param (        
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "Environments?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusLibrarySetList {
    param (
        $octopusData
    )
    
    return Get-OctopusApiItemList -EndPoint "libraryvariablesets?skip=0&take=1000&contentType=Variables" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusVariableSetVariables {
    param (
        $variableSet,
        $octopusData
    )
    
    return Get-OctopusApi -EndPoint $variableSet.Links.Variables -ApiKey $octopusData.OctopusApiKey -SpaceId $null -OctopusUrl $octopusData.OctopusUrl 
}

Function Get-OctopusScriptModuleList {
    param (
        $octopusData
    )
    
    return Get-OctopusApiItemList -EndPoint "libraryvariablesets?skip=0&take=1000&contentType=ScriptModule" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusStepTemplateList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "actiontemplates?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusWorkerPoolList {
    param(
        $octopusData
    )

    
    return Get-OctopusApiItemList -EndPoint "workerpools?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusFeedList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "feeds?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusInfrastructureAccountList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "accounts?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

function Get-OctopusCommunityActionTemplateList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "communityactiontemplates?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
}

Function Get-OctopusTenantTagSetList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "tagsets?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusLifeCycleList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "lifecycles?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-ProjectGroupList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "projectgroups?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusTenantList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "tenants?skip=0&take=10000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusMachinePolicyList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "machinepolicies?skip=0&take=10000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusWorkerList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "workers?skip=0&take=10000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusTargetList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "machines?skip=0&take=10000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusTeamList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "teams?spaces=$($octopusData.SpaceId)&includeSystem=true" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
}

Function Get-OctopusUserList {
    param(        
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "users?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
}

Function Get-OctopusCertificateList {
    param(        
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "certificates?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

Function Get-OctopusUserRoleList {
    param(        
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "usersroles?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
}

function Get-OctopusProjectChannelList {
    param(
        $project,
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "projects/$($project.Id)/channels" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}

function Get-OctopusProjectDeploymentProcess {
    param(
        $project,
        $octopusData
    )

    $projectId = $project.Id
    if ($null -ne $octopusData.ProjectProcesses.$projectId) {
        return $octopusData.ProjectProcesses.$projectId
    }
    else {

        $isVersionControlled = $project.IsVersionControlled
        $deploymentProcessEndpoint = $project.Links.DeploymentProcess
        if ($isVersionControlled -eq $True) {
            # Get default branch
            $branch = $project.PersistenceSettings.DefaultBranch
            Write-OctopusWarning "Project '$($project.Name)' is version controlled, getting process from default branch: '$branch'"
            $deploymentProcessEndpoint = $deploymentProcessEndpoint.Replace("{gitRef}", $branch)
        }
        $deploymentProcess = Get-OctopusApi -EndPoint $deploymentProcessEndpoint -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
        # cache
        $octopusData.ProjectProcesses.$projectId = $deploymentProcess
        return $deploymentProcess
    }
}

function Get-OctopusProjectRunbookList {
    param(
        $project,
        $octopusData
    )

    $projectId = $project.Id
    if ($null -ne $octopusData.ProjectRunbooks.$projectId) {
        return $octopusData.ProjectRunbooks.$projectId
    }

    if ($projectId -notlike "Projects*") {
        return @()
    }

    $runbooks = Get-OctopusApiItemList -EndPoint "projects/$($project.Id)/runbooks" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
    # cache
    $octopusData.ProjectRunbooks.$projectId = $runbooks
    return $runbooks
}

function Get-OctopusRunbookProcess {
    param(
        $runbook,
        $octopusData
    )   

    $runbookId = $runbook.Id
    if ($null -ne $octopusData.ProjectRunbookProcesses.$runbookId) {
        return $octopusData.ProjectRunbookProcesses.$runbookId
    }

    $runbookProcess = Get-OctopusApi -EndPoint $runbook.Links.RunbookProcesses -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
    # cache
    $octopusData.ProjectRunbookProcesses.$runbookId = $runbookProcess
    return $runbookProcess
}

function Get-OctopusTeamScopedUserRoleList {
    param(
        $team,
        $octopusData           
    )

    return Get-OctopusApiItemList -EndPoint "teams/$($team.Id)/scopeduserroles?skip=0&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $null
}

function Get-OctopusPackageList {
    param(
        $octopusData
    )

    return Get-OctopusApiItemList -EndPoint "packages?filter=&latest=true&take=1000" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -spaceId $octopusData.SpaceId
}

function Get-OctopusPackage {
    param(
        $package,
        $octopusData,
        $filePath
    )

    $url = Get-OctopusUrl -EndPoint $package.Links.Raw -SpaceId $null -OctopusUrl $octopusData.OctopusUrl    

    return Invoke-OctopusApi -Method "Get" -Url $url -apiKey $octopusData.OctopusApiKey -filePath $filePath
}

function Get-OctopusItemLogo {
    param(
        $item,
        $octopusUrl,
        $apiKey,
        $filePath
    )

    $url = Get-OctopusUrl -EndPoint $item.Links.Logo -SpaceId $null -OctopusUrl $OctopusUrl

    return Invoke-OctopusApi -Method "Get" -Url $url -apiKey $ApiKey -filePath $filePath
}

function Get-OctopusCertificateExport {
    param (
        $certificate,
        $octopusData,
        $filePath
    )

    $url = Get-OctopusUrl -EndPoint "certificates/$($certificate.Id)/export?includePrivateKey=false&pemOptions=PrimaryOnly" -SpaceId $octopusData.SpaceId -OctopusUrl $octopusData.OctopusUrl

    return Invoke-OctopusApi -Method "Get" -Url $url -apiKey $octopusData.OctopusApiKey -filePath $filePath
}

function Get-OctopusTenantVariables {
    param (
        $octopusData,
        $tenant
    )

    return Get-OctopusApi -EndPoint "tenants/$($tenant.Id)/variables" -ApiKey $octopusData.OctopusApiKey -OctopusUrl $octopusData.OctopusUrl -SpaceId $octopusData.SpaceId
}
