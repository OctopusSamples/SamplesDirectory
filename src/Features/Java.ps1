<#
.SYNOPSIS
Looks for the Java feature within a deployment or runbook step.

.DESCRIPTION
The catalog criteria for the Java feature is:

1. The built-in "Deploy to Tomcat via Manager" step which is indicated by ActionType = Octopus.TomcatDeploy.
2. The built-in "Deploy a certificate to Tomcat" step which is indicated by ActionType = Octopus.TomcatDeployCertificate.
3. The built-in "Start/Stop App in Tomcat" step which is indicated by ActionType = Octopus.TomcatState.
4. The built-in "Deploy to Wildfly or EAP" step which is indicated by ActionType = Octopus.WildFlyDeploy.
5. The built-in "Configure certificate for Wildfly or EAP" step which is indicated by ActionType = Octopus.WildFlyCertificateDeploy.
6. The built-in "Enable/Disable deployment in Wildfly or EAP" step which is indicated by ActionType = Octopus.WildFlyState.
7. A step template (either custom or from the Community library) with the word 'Tomcat' contained within the name.
8. A step template (either custom or from the Community library) with the word 'WildFly' contained within the name.
#>
function Find-JavaFeatureInStep {
    param(
        [Object[]]
        $items, 
        $source,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "Java" -source $source -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -eq $itemToCatalog.Feature -and $args[0].Source -eq $itemToCatalog.Source -and $args[0].ProjectId -eq $itemToCatalog.ProjectId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Deploy to Tomcat via Manager
    if ($step.Actions[0].ActionType -eq "Octopus.TomcatDeploy") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy to Tomcat via Manager' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy a certificate to Tomcat
    if ($step.Actions[0].ActionType -eq "Octopus.TomcatDeployCertificate") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy a certificate to Tomcat' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Start/Stop App in Tomcat
    if ($step.Actions[0].ActionType -eq "Octopus.TomcatState") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Start/Stop App in Tomcat' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy to Wildfly or EAP
    if ($step.Actions[0].ActionType -eq "Octopus.WildFlyDeploy") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Deploy to Wildfly or EAP' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Configure certificate for Wildfly or EAP
    if ($step.Actions[0].ActionType -eq "Octopus.WildFlyCertificateDeploy") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Configure certificate for Wildfly or EAP' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Enable/Disable deployment in Wildfly or EAP
    if ($step.Actions[0].ActionType -eq "Octopus.WildFlyState") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the 'Enable/Disable deployment in Wildfly or EAP' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Check step for any step template containing the name 'Tomcat'
    if (Test-StepTemplateNameContainsValue -step $step -name "Tomcat" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'Tomcat' in it." 
        $items += $itemToCatalog
        return $items;
    }
    # Check step for any step template containing the name 'WildFly'
    if (Test-StepTemplateNameContainsValue -step $step -name "WildFly" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'WildFly' in it." 
        $items += $itemToCatalog
        return $items;
    }
    return $items;
}