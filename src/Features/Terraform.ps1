<#
.SYNOPSIS
Finds the Terraform feature within projects.

.DESCRIPTION
The catalog criteria for the Terraform feature is:

1. The built-in "Apply a Terraform template" step which is indicated by ActionType = Octopus.TerraformApply.
2. The built-in "Destroy terraform resources" step which is indicated by ActionType = Octopus.TerraformDestroy.
3. The built-in "Plan to apply a Terraform template" step which is indicated by ActionType = Octopus.TerraformPlan.
4. The built-in "Plan a Terraform destroy" step which is indicated by ActionType = Octopus.TerraformPlanDestroy.
5. A step template (either custom or from the Community library) with the word 'Terraform' contained within the name.
#>

function Find-TerraformFeatureInStep {
    param(
        [Object[]]
        $items,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "Terraform" -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -eq $itemToCatalog.Feature -and $args[0].ProjectId -eq $itemToCatalog.ProjectId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Apply a Terraform template
    if ($step.Actions[0].ActionType -eq "Octopus.TerraformApply") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in Terraform apply step." 
        $items += $itemToCatalog
        return $items;
    }
    # Destroy terraform resources
    if ($step.Actions[0].ActionType -eq "Octopus.TerraformDestroy") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in Terraform destroy step." 
        $items += $itemToCatalog
        return $items;
    }
    # Plan to apply a Terraform template
    if ($step.Actions[0].ActionType -eq "Octopus.TerraformPlan") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in Terraform plan step." 
        $items += $itemToCatalog
        return $items;
    }
    # Plan a Terraform destroy
    if ($step.Actions[0].ActionType -eq "Octopus.TerraformPlanDestroy") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in Terraform plan destroy step." 
        $items += $itemToCatalog
        return $items;
    }

    # Check deployment step for any step template containing the name 'Terraform'
    if (Test-StepTemplateNameContainsValue -step $step -name "Terraform" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template in the deployment process with the word Terraform in it." 
        $items += $itemToCatalog
        return $items;
    }

    return $items;
}