<#
.SYNOPSIS
Looks for the AWS feature within a deployment or runbook step.

.DESCRIPTION
The catalog criteria for the Azure feature is:

1. The built-in "Run an AWS CLI Script" step which is indicated by ActionType = Octopus.AwsRunScript.
2. The built-in "Deploy an AWS CloudFormation template" step which is indicated by ActionType = Octopus.AwsRunCloudFormation.
3. The built-in "Apply an AWS CloudFormation Change Set" step which is indicated by ActionType = Octopus.AwsApplyCloudFormationChangeSet
4. The built-in "Delete an AWS CloudFormation stack" step which is indicated by ActionType = Octopus.AwsDeleteCloudFormation.
5. The built-in "Upload a package to an AWS S3 bucket" step which is indicated by ActionType = Octopus.AwsUploadS3.
6. The built-in "Deploy Amazon ECS Service" step which is indicated by ActionType = Octopus.aws-ecs.
7. The built-in "Update Amazon ECS Service" step which is indicated by ActionType = Octopus.aws-ecs-update-service.
8. A step template (either custom or from the Community library) with the word 'Amazon' contained within the name.
9. A step template (either custom or from the Community library) with the word 'AWS' contained within the name.
#>

function Find-AwsFeatureInStep {
    param(
        [Object[]]
        $items,
        $step,
        $octopusData,
        $project
    )
    $itemToCatalog = Get-FeatureItem -feature "AWS" -octopusData $octopusData -project $project
    $haveMatchingItem = Get-FirstOrDefault -items $items -delegate ({ $args[0].Feature -eq $itemToCatalog.Feature -and $args[0].ProjectId -eq $itemToCatalog.ProjectId })

    if ($null -ne $haveMatchingItem) {
        return $items;
    }

    # Run an AWS CLI Script
    if ($step.Actions[0].ActionType -eq "Octopus.AwsRunScript") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Run an AWS CLI Script' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy an AWS CloudFormation template
    if ($step.Actions[0].ActionType -eq "Octopus.AwsRunCloudFormation") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy an AWS CloudFormation template' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Apply an AWS CloudFormation Change Set
    if ($step.Actions[0].ActionType -eq "Octopus.AwsApplyCloudFormationChangeSet") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Apply an AWS CloudFormation Change Set' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Delete an AWS CloudFormation stack
    if ($step.Actions[0].ActionType -eq "Octopus.AwsDeleteCloudFormation") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Delete an AWS CloudFormation stack' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Upload a package to an AWS S3 bucket
    if ($step.Actions[0].ActionType -eq "Octopus.AwsUploadS3") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Upload a package to an AWS S3 bucket' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Deploy Amazon ECS Service
    if ($step.Actions[0].ActionType -eq "Octopus.aws-ecs") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Deploy Amazon ECS Service' step." 
        $items += $itemToCatalog
        return $items;
    }
    # Update Amazon ECS Service
    if ($step.Actions[0].ActionType -eq "Octopus.aws-ecs-update-service") { 
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has the built-in 'Update Amazon ECS Service' step." 
        $items += $itemToCatalog
        return $items;
    }

    # Check deployment step for any step template containing the name 'Amazon'
    if (Test-StepTemplateNameContainsValue -step $step -name "Amazon" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'Amazon' in it." 
        $items += $itemToCatalog
        return $items;
    }
    # Check deployment step for any step template containing the name 'AWS'
    if (Test-StepTemplateNameContainsValue -step $step -name "AWS" -octopusData $octopusData) {
        Write-OctopusSuccess " - Project '$($project.Name)' ($($project.Id)) has a step template with the word 'AWS' in it." 
        $items += $itemToCatalog
        return $items;
    }

    return $items;
}