param (
    [string]$CatalogItemsFilePath,
    [string]$MarkDownFilePath
)

$ErrorActionPreference = "Stop"
$CatalogItemsContent = Get-Content $CatalogItemsFilePath | ConvertFrom-Json
$FeatureGroups = $CatalogItemsContent | Group-Object -Property Feature
$MarkDownContent = @()
foreach ($FeatureGroup in $FeatureGroups) {
    $FeatureName = $FeatureGroup.Name
    $MarkDownContent += "### $($FeatureName)"
    $SpaceGroups = $FeatureGroup.Group | Group-Object -Property SpaceName

    foreach ($SpaceGroup in $SpaceGroups) {
        $SpaceName = $SpaceGroup.Name
        $MarkDownContent += "- **$($SpaceName)**"
        $Projects = $SpaceGroup.Group | Sort-Object -Property ProjectName
        foreach ($Project in $Projects) {
            $ProjectName = $Project.ProjectName
            $ProjectUrl = $Project.ProjectLink
            $ProjectDescription = $Project.ProjectDescription
            $MarkDownContent += "  - [$($ProjectName)]($($ProjectUrl))"
            $MarkDownContent += @"  
  <dd>
  
  $($ProjectDescription)
  
  </dd>
            
"@
        }
    }
}

New-Item -Path $MarkDownFilePath -ItemType File 
Set-Content -Path $MarkDownFilePath -Value $MarkDownContent