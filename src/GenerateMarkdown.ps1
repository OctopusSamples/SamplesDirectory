param (
    [string]$CatalogItemsFilePath,
    [string]$MarkDownFilePath
)

$ErrorActionPreference = "Stop"
$CatalogItemsContent = Get-Content $CatalogItemsFilePath | ConvertFrom-Json
$FeatureGroups = $CatalogItemsContent | Group-Object -Property Feature | Sort-Object -Property Name
$MarkDownContent = @()

foreach ($FeatureGroup in $FeatureGroups) {
    $FeatureName = $FeatureGroup.Name
    
    $MarkDownContent += "### $($FeatureName)"
    $SpaceGroups = $FeatureGroup.Group | Group-Object -Property SpaceName

    foreach ($SpaceGroup in $SpaceGroups) {
        $SpaceName = $SpaceGroup.Name
        $MarkDownContent += "
**$($SpaceName)**"
        $Projects = $SpaceGroup.Group | Sort-Object -Property ProjectName
        foreach ($Project in $Projects) {
            $Id = "more-$($featureName)-$($project.SpaceId)-$($project.ProjectId)".ToLowerInvariant()
            $ProjectName = $Project.ProjectName
            $ProjectDescription = $Project.ProjectDescription
            $ProjectUrl = $Project.ProjectLink
            $ProjectMarkdown = "  - [$($ProjectName)]($($ProjectUrl))"
            
            if (![string]::IsNullOrWhitespace($ProjectDescription)) {
                # Flatten new lines
                $ProjectDescription = ($ProjectDescription -Replace "`n", " ") -Replace "  ", " "
            
                $ProjectDescParts = ($ProjectDescription -Split " ")
                if ($ProjectDescParts.Length -gt 10) {
                    $InitialDescParts = $ProjectDescParts | Select-Object -First 10
                    $InitialDescription = ($InitialDescParts | Join-String -Separator " ").Trim()
                    $ProjectMarkdown += ": *$InitialDescription*"
                    $RemainingDescParts = $ProjectDescParts | Select-Object -Skip 10
                    $RemainingDescription = ($RemainingDescParts | Join-String -Separator " ").Trim()
                    $ProjectMarkdown += "<span class='collapse' id='$Id'> *$($RemainingDescription.Trim())*</span>
<span>
<a href='#$Id' data-toggle='collapse'> ...</a>
</span>
"
                }
                else {
                    $ProjectMarkdown += ": *$ProjectDescription*
                    "
                }
            }
            $MarkDownContent += $ProjectMarkdown
        }
    }
}

New-Item -Path $MarkDownFilePath -ItemType File -Force
Set-Content -Path $MarkDownFilePath -Value $MarkDownContent -Force