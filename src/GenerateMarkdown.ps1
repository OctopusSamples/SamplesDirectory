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
$SourceGroups = $CatalogItemsContent | Group-Object -Property SourceType | Sort-Object -Property Name

foreach ($source in $SourceGroups) {
    $sourceName = $source.Name -Replace "process", ""

    $FeatureGroups = $source.Group | Group-Object -Property Feature | Sort-Object -Property Name
    
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
            
            switch ($sourceName) {
                "runbook" {
                    $Projects = $SpaceGroup.Group | Group-Object -Property ProjectName | Sort-Object -Property Name
                    foreach ($project in $Projects) {
                        $ProjectName = $Project.Name
                        
                        $MarkdownContent += "
- $($ProjectName)"
                        $runbooks = $project.Group | Sort-Object -Property SourceName
                        foreach ($runbook in $runbooks) {
                            $RunbookName = $runbook.SourceName
                            $SourceDescription = $runbook.SourceDescription
                            $SourceLink = $runbook.SourceLink
                            $runbookMarkdown = "
   - <a href=`"$($SourceLink)`" target=`"_blank`">$($RunbookName)</a>"
                            if (![string]::IsNullOrWhitespace($SourceDescription)) {
                                $SourceDescription = ($SourceDescription -Replace "  ", " ").Trim()
                                # Attempt to make bullet points better
                                $SourceDescription = ($SourceDescription -Replace "`n- ", "`n      - ").Trim()
                                $runbookMarkdown += ": <i>$SourceDescription</i>"
                            }
                            $MarkdownContent += $runbookMarkdown
                        }
                    }
                }
                "deployment" {
                    $Projects = $SpaceGroup.Group | Sort-Object -Property Name
                    
                    foreach ($project in $Projects) {
                        $ProjectName = $Project.ProjectName
                        $SourceDescription = $Project.SourceDescription
                        $SourceLink = $Project.SourceLink
                        $markdown = "
- <a href=`"$($SourceLink)`" target=`"_blank`">$($ProjectName)</a>"
                        if (![string]::IsNullOrWhitespace($SourceDescription)) {
                            $SourceDescription = (($SourceDescription -Replace "`n", " ") -Replace "  ", " ").Trim()
                            $markdown += ": <i>$SourceDescription</i>"
                        }
                        $MarkdownContent += $markdown
                    }
                }
                default {
                    throw "Unknown '$sourceName' provided to generate markdown files!"
                }
            }
            
            $counter++
        }
        Write-Host "Setting markdown content for $Feature in $MarkdownFilePath"
        Set-Content -Path $MarkdownFilePath -Value $MarkdownContent -Force
    }
}