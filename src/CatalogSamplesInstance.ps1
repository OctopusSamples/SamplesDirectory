param (
    [Parameter(Mandatory = $false)]
    $OctopusUrl = "https://your.octopus.app",
    [Parameter(Mandatory = $false)]
    $OctopusApiKey = "API-YOURKEY",
    [Parameter(Mandatory = $false)]
    $OutputResults = $False
)

# Include helpers
. ([System.IO.Path]::Combine($PSScriptRoot, "Logging.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "OctopusApiUtils.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "OctopusData.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "OctopusRepository.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Utils.ps1"))

# Include feature processors
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "IIS.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "Java.ps1"))
. ([System.IO.Path]::Combine($PSScriptRoot, "Features", "Kubernetes.ps1"))

$ErrorActionPreference = "Stop"

$catalogStartDateTime = Get-Date
$OctopusUrl = $OctopusUrl.TrimEnd("/")
[Object[]]$items = @()

$SpaceList = Get-OctopusSpaceList -octopusUrl $OctopusUrl -octopusApiKey $OctopusApiKey

foreach ($space in $SpaceList) {
    Write-Host "`nStarting catalog of space '$($space.Name)'`n"
    
    $octopusData = Get-OctopusData -octopusUrl $OctopusUrl -octopusApiKey $OctopusApiKey -space $Space
    $projects = $octopusData.ProjectList
    foreach ($project in $projects) {
        Write-OctopusSuccess "Checking project '$($project.Name)' for features"
        
        # Check each project deployment process.
        $deploymentProcess = Get-OctopusProjectDeploymentProcess -project $project -octopusData $octopusData
        foreach ($deploymentstep in $deploymentProcess.Steps) {
            $items = @(Find-IISFeatureInStep -items $items -step $deploymentstep -octopusData $octopusData -project $project)
            $items = @(Find-JavaFeatureInStep -items $items -step $deploymentstep -octopusData $octopusData -project $project)
            $items = @(Find-KubernetesFeatureInStep -items $items -step $deploymentstep -octopusData $octopusData -project $project)
            
            # Add more features here...
        }

        # Check runbook processes
        Write-Verbose "Getting runbooks for project '$($project.Name)'"
        $projectRunbooks = Get-OctopusProjectRunbookList -project $project -octopusData $octopusData
        foreach ($runbook in $projectRunbooks) {
            $runbookProcess = Get-OctopusRunbookProcess -runbook $runbook -octopusData $octopusData
            foreach ($runbookStep in $runbookProcess.Steps) {
                $items = @(Find-IISFeatureInStep -items $items -step $runbookStep -octopusData $octopusData -project $project)
                $items = @(Find-JavaFeatureInStep -items $items -step $runbookStep -octopusData $octopusData -project $project)
                $items = @(Find-KubernetesFeatureInStep -items $items -step $runbookStep -octopusData $octopusData -project $project)
                
                # Add more features here...
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