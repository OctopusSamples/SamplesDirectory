param (
    [string]$CatalogItemsFilePath,
    [string]$MarkDownFilePath
)

$CatalogItemsContent = Get-Content $CatalogItemsFilePath | ConvertFrom-Json
$FeatureGroups = $CatalogItemsContent | Group-Object -Property Feature
$MarkDownFilePath = $MarkDownFilePath
$MarkDownContent = @()

foreach($FeatureGroup in $FeatureGroups) {
    $MarkDownContent += "<details>"
    $FeatureName = $FeatureGroup.Name
    $MarkDownContent += @"
    <summary>$($FeatureName)</summary>
    
"@

    $SpaceGroups = $FeatureGroup.Group | Group-Object -Property SpaceName

    foreach($SpaceGroup in $SpaceGroups) {
        $SpaceName = $SpaceGroup.Name
        $MarkDownContent += "- *Space:* **$($SpaceName)**"
        $Projects = $SpaceGroup.Group

        foreach($Project in $Projects) {
            $ProjectName = $Project.ProjectName
            $ProjectUrl = $Project.ProjectLink

            $MarkDownContent += "  - *Project:* [$($ProjectName)]($($ProjectUrl))"
        }

    }

    $MarkDownContent += "</details>"
}

New-Item -Path $MarkDownFilePath -ItemType File 
Set-Content -Path $MarkDownFilePath -Value $MarkDownContent