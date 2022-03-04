<#
.SYNOPSIS
Looks for the Azure feature within a deployment or runbook step.

.DESCRIPTION
The catalog criteria for the Azure feature is:

1. The built-in "Deploy an Azure App Service" step which is indicated by ActionType = Octopus.AzureAppService.
2. The built-in "Run an Azure Script" step which is indicated by ActionType = Octopus.AzurePowershell.
3. The built-in "Deploy an Azure Web App (Web Deploy)" step which is indicated by ActionType = Octopus.AzureWebApp
4. The built-in "Deploy an Azure Resource Manager template" step which is indicated by ActionType = Octopus.AzureResourceGroup.
5. The built-in "Deploy a Service Fabric App" step which is indicated by ActionType = Octopus.AzureServiceFabricApp.
6. The built-in "Run a Service Fabric SDK PowerShell Script" step which is indicated by ActionType = Octopus.AzureServiceFabricPowershell.
7. The built-in "Deploy an Azure Cloud Service" step which is indicated by ActionType = Octopus.AzureCloudService.
8. A step template (either custom or from the Community library) with the word 'Azure' contained within the name.
#>

function Find-AzureFeatureInStep {
    param(
        [Object[]]
        $items,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "Azure" -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -eq $itemToCatalog.Feature -and $args[0].ProjectId -eq $itemToCatalog.ProjectId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Deploy an Azure App Service
    if ($step.Actions[0].ActionType -eq "Octopus.AzureAppService") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy an Azure App Service' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Run an Azure Script
    if ($step.Actions[0].ActionType -eq "Octopus.AzurePowershell") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Run an Azure Script' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy an Azure Web App (Web Deploy)
    if ($step.Actions[0].ActionType -eq "Octopus.AzureWebApp") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy an Azure Web App (Web Deploy)' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy an Azure Resource Manager template
    if ($step.Actions[0].ActionType -eq "Octopus.AzureResourceGroup") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy an Azure Resource Manager template' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy a Service Fabric App
    if ($step.Actions[0].ActionType -eq "Octopus.AzureServiceFabricApp") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy a Service Fabric App' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Run a Service Fabric SDK PowerShell Script
    if ($step.Actions[0].ActionType -eq "Octopus.AzureServiceFabricPowershell") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Run a Service Fabric SDK PowerShell Script' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy an Azure Cloud Service
    if ($step.Actions[0].ActionType -eq "Octopus.AzureCloudService") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy an Azure Cloud Service' step." 
        $items += $itemToCatalog
        return $items;
    }

    # Check deployment step for any step template containing the name 'Azure'
    if (Test-StepTemplateNameContainsValue -step $step -name "Azure" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template in the deployment process with the word 'Azure' in it." 
        $items += $itemToCatalog
        return $items;
    }

    return $items;
}