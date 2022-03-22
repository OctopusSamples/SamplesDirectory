param (
    [string]$CatalogItemsFilePath,
    [string]$MarkdownTargetFolder
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $MarkdownTargetFolder)) {
    Write-Host "Creating directory $MarkdownTargetFolder"
    New-Item -ItemType Directory -Path $MarkdownTargetFolder -Force
}

$CatalogItemsContent = Get-Content $CatalogItemsFilePath | ConvertFrom-Json
$SourceGroups = $CatalogItemsContent | Group-Object -Property Source | Sort-Object -Property Name

foreach ($source in $SourceGroups) {
    $sourceName = $source.Name -Replace "process", ""

    $FeatureGroups = $source.Group | Group-Object -Property Feature | Sort-Object -Property Name
    $MarkdownContent = @()
    
    foreach ($feature in $FeatureGroups) {
        $FeatureName = $feature.Name
        $FeatureFileName = "samples-$($FeatureName.ToLowerInvariant() -Replace " ","-")-$($sourceName)-feature-list.include.md"
        $MarkdownFilePath = ([System.IO.Path]::Combine($MarkdownTargetFolder, "$FeatureFileName"))
        New-Item -Path $MarkdownFilePath -ItemType File -Force
        $MarkdownContent = ""
        $SpaceGroups = $feature.Group | Group-Object -Property SpaceName
        $counter = 1
        foreach ($SpaceGroup in $SpaceGroups) {
            $SpaceName = $SpaceGroup.Name
            if ($counter -eq 1) {
                $MarkdownContent += "**$($SpaceName)**
"
            }
            else {
                $MarkdownContent += "
    
**$($SpaceName)**
"
            }
            
            $Projects = $SpaceGroup.Group | Sort-Object -Property ProjectName
            foreach ($Project in $Projects) {
                $ProjectName = $Project.ProjectName
                $ProjectDescription = $Project.ProjectDescription
                $ProjectUrl = $Project.SourceLink
                $ProjectMarkdown = "
- <a href=`"$($ProjectUrl)`" target=`"_blank`">$($ProjectName)</a>"
                
                if (![string]::IsNullOrWhitespace($ProjectDescription)) {
                    # Flatten new lines
                    $ProjectDescription = (($ProjectDescription -Replace "`n", " ") -Replace "  ", " ").Trim()
                    $ProjectMarkdown += ": *$ProjectDescription*"
                }
                $MarkdownContent += $ProjectMarkdown
            }
            $counter++
        }
        Write-Host "Setting markdown content for $Feature in $MarkdownFilePath"
        Set-Content -Path $MarkdownFilePath -Value $MarkdownContent -Force
    }
}
