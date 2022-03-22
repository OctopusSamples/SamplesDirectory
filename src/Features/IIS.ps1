<#
.SYNOPSIS
Looks for the IIS feature within a deployment or runbook step.

.DESCRIPTION
The catalog criteria for the IIS feature is:

1. The built-in "Deploy to IIS" step which is indicated by ActionType = Octopus.IIS.
2. The built-in "Deploy a Package" step with the IIS Web Site and Application Pool feature enabled which is indicated by Action Property 'Octopus.Action.EnabledFeatures' with value 'Octopus.Features.IISWebSite' within it.
3. A step template (either custom or from the Community library) with the word 'IIS' contained within the name.
#>

function Find-IISFeatureInStep {
    param(
        [Object[]]
        $items,
        $source,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "IIS" -source $source -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -eq $itemToCatalog.Feature -and $args[0].Source -eq $itemToCatalog.Source -and $args[0].ProjectId -eq $itemToCatalog.ProjectId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Deploy to IIS
    if ($step.Actions[0].ActionType -eq "Octopus.IIS") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy to IIS' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Check for package step with enabled feature
    if (Test-PropertyExistsAndContainsValue -inputObject $step.Actions[0].Properties -name "Octopus.Action.EnabledFeatures" - value "Octopus.Features.IISWebSite") {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a package step with the IIS feature enabled." 
        $items += $itemToCatalog
        return $items;
    }
    # Check deployment step for any step template containing the name 'IIS'
    if (Test-StepTemplateNameContainsValue -step $step -name "IIS" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'IIS' in it." 
        $items += $itemToCatalog
        return $items;
    }

    return $items;
}