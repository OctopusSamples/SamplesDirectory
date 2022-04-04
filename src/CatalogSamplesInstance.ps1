<#
.SYNOPSIS
Catalogs samples instance features

.DESCRIPTION
Takes the following input parameters:
    - OctopusURL
    - OctopusAPIKey
    - OutputResults
    - ExcludedProjects which is a comma separated list of space/project names in the format:
      -> Space Infrastructure -> excludes any projects with that name on any space
      -> [Space Name]|Space Infrastructure -> excludes any projects with that name on a specific space.
    - IgnoreErrors
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$OctopusUrl = "https://your.octopus.app",
    [Parameter(Mandatory = $false)]
    [string]$OctopusApiKey = "API-YOURKEY",
    [Parameter(Mandatory = $false)]
    [bool]$OutputResults = $False,
    [Parameter(Mandatory = $false)]
    [string]$ExcludeProjects = $null,
    [Parameter(Mandatory = $false)]
    [bool]$IgnoreErrors = $False
)

# Include helpers
. ([System.IO.Path]::Combine($PSScriptRoot, "Logging.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "OctopusApiUtils.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "OctopusData.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "OctopusRepository.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Utils.ps1"))

# Include feature processors
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "AWS.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "Azure.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "GoogleCloud.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "IIS.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "Java.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "Kubernetes.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "Terraform.ps1"))

$ErrorActionPreference = "Stop"

$catalogStartDateTime = Get-Date
$OctopusUrl = $OctopusUrl.TrimEnd("/")
[Object[]]$items = @()

[PsCustomObject[]]$ExcludedProjects = @()

Write-Host "Establishing any projects to exclude."
if (![string]::IsNullOrWhitespace($ExcludeProjects)) {
    @(($ExcludeProjects -Split ",").Trim()) | ForEach-Object {
        Write-Verbose "Working on: '$_'"
        $exclusionDefinition = ($_ -Split "\|")
        $project = $exclusionDefinition[0].Trim()
        $space = $null
        if ($exclusionDefinition.Count -gt 1) {
            $space = $exclusionDefinition[0].Trim()
            $project = $exclusionDefinition[1].Trim()
        }
        if ([string]::IsNullOrWhiteSpace($project)) {
            throw "Unable to establish project name from: '$($_)'"
        }
        $excludedProject = [PsCustomObject]@{
            Space   = $space
            Project = $project
        }
        $ExcludedProjects += $excludedProject
    }
}

if ($ExcludedProjects.Count -gt 0) {
    Write-Host "Projects Exclusion criteria: $($ExcludedProjects.Count)"
}

$SpaceList = Get-OctopusSpaceList -octopusUrl $OctopusUrl -octopusApiKey $OctopusApiKey

foreach ($space in $SpaceList) {
    Write-Host "`nStarting catalog of space '$($space.Name)'`n"
    
    $octopusData = Get-OctopusData -octopusUrl $OctopusUrl -octopusApiKey $OctopusApiKey -space $Space
    $projects = $octopusData.ProjectList
    foreach ($project in $projects) {
        try {
            # First, check if project is one to be excluded:
            $matchingProject = Get-FirstOrDefault -items $ExcludedProjects -delegate ({ $args[0].Project -ieq $project.Name -and ($args[0].Space -ieq $space.Name -or [string]::IsNullOrWhiteSpace($args[0].Space)) })
            if ($null -eq $matchingProject) {
                Write-OctopusSuccess "Checking project '$($project.Name)' for features"
        
                # Check each project deployment process.
                $deploymentProcess = Get-OctopusProjectDeploymentProcess -project $project -octopusData $octopusData
                $source = Get-SourceForDeploymentProcess -project $project -deploymentProcess $deploymentProcess
                foreach ($deploymentstep in $deploymentProcess.Steps) {
                    $items = @(Find-AwsFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                    $items = @(Find-AzureFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                    $items = @(Find-GoogleCloudFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                    $items = @(Find-IISFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                    $items = @(Find-JavaFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                    $items = @(Find-KubernetesFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                    $items = @(Find-TerraformFeatureInStep -items $items -source $source -step $deploymentstep -octopusData $octopusData -project $project)
                }

                # Check runbook processes
                Write-Verbose "Getting runbooks for project '$($project.Name)'"
                $projectRunbooks = Get-OctopusProjectRunbookList -project $project -octopusData $octopusData
                foreach ($runbook in $projectRunbooks) {
                    $runbookProcess = Get-OctopusRunbookProcess -runbook $runbook -octopusData $octopusData
                    $source = Get-SourceForRunbookProcess -project $project -runbook $runbook -runbookProcess $runbookProcess
                    foreach ($runbookStep in $runbookProcess.Steps) {
                        $items = @(Find-AwsFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                        $items = @(Find-AzureFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                        $items = @(Find-GoogleCloudFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                        $items = @(Find-IISFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                        $items = @(Find-JavaFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                        $items = @(Find-KubernetesFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                        $items = @(Find-TerraformFeatureInStep -items $items -source $source -step $runbookStep -octopusData $octopusData -project $project)
                    }
                }
            }
            else {
                Write-Host "Skipping project '$($project.Name)' as it matches a project exclusion entry."
            }
        }
        catch {
            $ExceptionMessage = $_.Exception.Message
            if($IgnoreErrors -eq $True) {
                Write-Warning "Skipping error in catalog process for project '$($project.Name)': $($ExceptionMessages)"
            } 
            else {
                throw $_
            }
        }
    } 
}

$catalogEndDateTime = Get-Date
$catalogElapsedTime = New-TimeSpan $catalogStartDateTime $catalogEndDateTime

Write-Host "It took $($catalogElapsedTime.ToString("hh\:mm\:ss\.ff")) for the catalog process to finish."
Write-Host "Found $($items.Length) item(s).`n"

# Sort items
$items = $items | Sort-Object -Property ProjectId

If ($OutputResults -eq $True) {
    $items | Format-List  
}
else {
    return $items
}