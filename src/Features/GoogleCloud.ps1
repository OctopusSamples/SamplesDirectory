<#
.SYNOPSIS
Looks for the Google Cloud feature within a deployment or runbook step.

.DESCRIPTION
The catalog criteria for the Google Cloud feature is:

1. The built-in "Run gcloud in a Script" step which is indicated by ActionType = Octopus.GoogleCloudScripting.
2. A step template (either custom or from the Community library) with the word 'Google' contained within the name.
3. A step template (either custom or from the Community library) with the word 'GCP' contained within the name.
#>

function Find-GoogleCloudFeatureInStep {
    param(
        [Object[]]
        $items,
        $source,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "Google Cloud" -source $source -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -ieq $itemToCatalog.Feature -and $args[0].ProjectId -ieq $itemToCatalog.ProjectId -and $args[0].SourceId -ieq $itemToCatalog.SourceId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Run gcloud in a Script
    if ($step.Actions[0].ActionType -eq "Octopus.GoogleCloudScripting") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Run gcloud in a Script' step in '$($source.Id)'." 
        $items += $itemToCatalog
        return $items;
    }

    # Check deployment step for any step template containing the name 'Google'
    if (Test-StepTemplateNameContainsValue -step $step -name "Google" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'Google' in it, in '$($source.Id)'." 
        $items += $itemToCatalog
        return $items;
    }

    # Check deployment step for any step template containing the name 'GCP'
    if (Test-StepTemplateNameContainsValue -step $step -name "GCP" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'GCP' in it, in '$($source.Id)'." 
        $items += $itemToCatalog
        return $items;
    }

    return $items;
}