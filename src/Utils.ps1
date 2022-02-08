function Get-FirstOrDefault {
    param(
        [Object[]]
        $items,
        [Func[Object, bool]]
        $delegate
    ) 
    return [Linq.Enumerable]::FirstOrDefault($items, $delegate);
}

function Get-FeatureItem {
    param(
        $feature,
        $octopusData,
        $project
    )
    
    $item = [PSCustomObject]@{
        Feature     = $feature;
        SpaceId     = $octopusData.SpaceId;
        SpaceName   = $octopusData.SpaceName;
        ProjectId   = $project.Id;
        ProjectName = $project.Name;
        ProjectLink = $octopusData.octopusUrl + $project.Links.Web
    }
    return $item
}

function Test-PropertyExistsAndContainsValue {
    param(
        $inputObject,
        $name,
        $value
    )

    if (Get-Member -inputObject $inputObject -Name $name -MemberType Properties) {
        $propertyValue = $inputObject.$name;
        if ([string]::IsNullOrWhitespace($propertyValue)) {
            return $False;
        }
        $result = ($propertyValue.IndexOf($value, [System.StringComparison]::InvariantCultureIgnoreCase) -ge 0);
        return $result;
    }
    return $False;
}

function Test-StepTemplateNameContainsValue {
    param(
        $step,
        $name,
        $octopusData
    )
    $actionTemplateIdName = "Octopus.Action.Template.Id"
    # Check to see if there is a step template linked.
    if (Get-Member -inputObject $step.Actions[0].Properties -Name $actionTemplateIdName -MemberType Properties) {
        $actionTemplateId = $step.Actions[0].Properties.$actionTemplateIdName;
        $stepTemplate = $octopusData.StepTemplates | Where-Object { $_.Id -eq $actionTemplateId } | Select-Object -First 1
        $stepTemplateName = $stepTemplate.Name;
        if ([string]::IsNullOrWhitespace($stepTemplateName)) {
            return $False;
        }
        $result = ($stepTemplateName.IndexOf($name, [System.StringComparison]::InvariantCultureIgnoreCase) -ge 0);
        return $result;
    }

    return $False;
}