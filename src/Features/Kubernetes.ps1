<#
.SYNOPSIS
Looks for the Kubernetes feature within a deployment or runbook step.

.DESCRIPTION
The catalog criteria for the Kubernetes feature is:

1. The built-in "Deploy Kubernetes containers" step which is indicated by ActionType = Octopus.KubernetesDeployContainers.
2. The built-in "Run a kubectl CLI Script" step which is indicated by ActionType = Octopus.KubernetesRunScript.
3. The built-in "Deploy raw Kubernetes YAML" step which is indicated by ActionType = Octopus.KubernetesDeployRawYaml.
4. The built-in "Deploy Kubernetes ingress resource" step which is indicated by ActionType = Octopus.KubernetesDeployIngress.
5. The built-in "Deploy Kubernetes secret resource" step which is indicated by ActionType = Octopus.KubernetesDeploySecret.
6. The built-in "Deploy Kubernetes service resource" step which is indicated by ActionType = Octopus.KubernetesDeployService.
7. The built-in "Deploy Kubernetes config map resource" step which is indicated by ActionType = Octopus.KubernetesDeployConfigMap.
8. The built-in "Upgrade a Helm Chart" step which is indicated by ActionType = Octopus.HelmChartUpgrade.
9. A step template (either custom or from the Community library) with the word 'Kubernetes' contained within the name.
10. A step template (either custom or from the Community library) with the word 'Helm' contained within the name.
#>
function Find-KubernetesFeatureInStep {
    param(
        [Object[]]
        $items,
        $source,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "Kubernetes" -source $source -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -eq $itemToCatalog.Feature -and $args[0].Source -eq $itemToCatalog.Source -and $args[0].ProjectId -eq $itemToCatalog.ProjectId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Deploy Kubernetes containers
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesDeployContainers") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy Kubernetes containers' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Run a kubectl CLI Script
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesRunScript") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Run a kubectl CLI Script' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy raw Kubernetes YAML
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesDeployRawYaml") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy raw Kubernetes YAML' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy Kubernetes ingress resource
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesDeployIngress") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy Kubernetes ingress resource' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy Kubernetes secret resource
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesDeploySecret") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy Kubernetes secret resource' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy Kubernetes service resource
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesDeployService") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy Kubernetes service resource' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy Kubernetes config map resource
    if ($step.Actions[0].ActionType -eq "Octopus.KubernetesDeployConfigMap") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy Kubernetes config map resource' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Upgrade a Helm Chart
    if ($step.Actions[0].ActionType -eq "Octopus.HelmChartUpgrade") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Upgrade a Helm Chart' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Check step for any step template containing the name 'Kubernetes'
    if (Test-StepTemplateNameContainsValue -step $step -name "Kubernetes" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'Kubernetes' in it." 
        $items += $itemToCatalog
        return $items;
    }
    # Check step for any step template containing the name 'Helm'
    if (Test-StepTemplateNameContainsValue -step $step -name "Helm" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'Helm' in it." 
        $items += $itemToCatalog
        return $items;
    }

    return $items;
}