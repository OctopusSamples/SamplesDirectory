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
            $ProjectName = $Project.ProjectName
            $ProjectDescription = $Project.ProjectDescription
            $ProjectUrl = $Project.ProjectLink
            $ProjectMarkdown = "  - <a href=`"$($ProjectUrl)`" target=`"_blank`">$($ProjectName)</a>"
            
            if (![string]::IsNullOrWhitespace($ProjectDescription)) {
                # Flatten new lines
                $ProjectDescription = (($ProjectDescription -Replace "`n", " ") -Replace "  ", " ").Trim()
                $ProjectMarkdown += ": *$ProjectDescription*
                "
            }
            $MarkDownContent += $ProjectMarkdown
        }
    }
}

New-Item -Path $MarkDownFilePath -ItemType File -Force
Set-Content -Path $MarkDownFilePath -Value $MarkDownContent -Force