
param (
    [Parameter(Mandatory = $false)]
    [string]$GitHubUsername,
    [Parameter(Mandatory = $false)]
    [string]$GitHubUserEmail,
    [Parameter(Mandatory = $false)]
    [string]$GitHubAccessToken,
    [Parameter(Mandatory = $false)]
    [string]$docsRepoOrg = "OctopusDeploy",
    [Parameter(Mandatory = $false)]
    [string]$docsRepoName = "docs",
    [Parameter(Mandatory = $false)]
    [string]$markDownFilePath,
    [Parameter(Mandatory = $false)]
    [string]$branchName,
    [Parameter(Mandatory = $false)]
    [bool]$WhatIf = $True
)

$ErrorActionPreference = "Stop"

# 0. Test for git
try {
    $version = git version
    Write-Verbose "$version is installed."
}
catch [System.Management.Automation.CommandNotFoundException] {
    Write-Error "Git is unavailable!"
    return
}

try {
    Write-Host "Installing 'PowerShellForGitHub' PowerShell module"
    Install-Module -Name PowerShellForGitHub -Force -AllowClobber

    $secureString = ($GitHubAccessToken | ConvertTo-SecureString -AsPlainText -Force)
    $cred = New-Object System.Management.Automation.PSCredential "username is ignored", $secureString
    Set-GitHubAuthentication -Credential $cred -SessionOnly
    Set-GitHubConfiguration -SuppressTelemetryReminder
    $secureString = $null # clear this out now that it's no longer needed
    $cred = $null # clear this out now that it's no longer needed
}
catch {
    Write-Error "An error occurred configuring the PowerShellForGitHub PS Module."
    return
}

if (!(Test-Path -Path $markDownFilePath)) {
    Write-Error "Markdown file at $($markDownFilePath) doesnt exist!"
    return
}

# Include helpers
. ([System.IO.Path]::Combine($PSScriptRoot, "Git.ps1"))

$docsRepoFullName = "$($docsRepoOrg)/$($docsRepoName)"
$docsDefaultBranch = "master"

if ([string]::IsNullOrWhitespace($branchName)) {
    $branchName = "enh-samplesdirectory-$([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'))"
}

# 1. Get the markdown file from the artifact stored in the runbook execution
$markdownContent = Get-Content $markDownFilePath

# 2. Checkout the docs repo from git
$tempCheckoutFolder = ([System.IO.Path]::Combine($PSScriptRoot, [System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid()))
$docsRepoFolderPath = ([System.IO.Path]::Combine($tempCheckoutFolder, "docs"))

New-ClonedRepo -checkoutFolder $tempCheckoutFolder -repoFullName $docsRepoFullName -username $GitHubUsername -accessToken $GitHubAccessToken

# 3. Check to see if file contents are the same. If they are, nothing to do
$existingMarkDownFilePath = ([System.IO.Path]::Combine($docsRepoFolderPath, "docs", "shared-content" , "samples", "samples-instance-features-list.include.md"))

if (!(Test-Path -Path $existingMarkDownFilePath)) {
    Write-Error "Existing markdown file could not be found at path: $existingMarkDownFilePath"
    return;
}
$existingMarkDownFileHash = Get-FileHash -Path $existingMarkDownFilePath
$newMarkDownFileHash = Get-FileHash -Path $markDownFilePath

Write-Verbose "Existing samples-instance-features-list.include.md FileHash: $($existingMarkDownFileHash.Hash)"
Write-Verbose "New content for features-list FileHash: $($newMarkDownFileHash.Hash)"

if ($existingMarkDownFileHash.Hash -ieq $newMarkDownFileHash.Hash) {
    Write-Host "New content file hash matches existing content file hash. Nothing to update"
    return;
}

# 4. Copy the contents to designated location
Set-Content -Path $existingMarkDownFilePath -Value $markdownContent

Write-Host "WhatIf set to True."

# 5. Create new branch and commit file
New-Branch -checkoutFolder $docsRepoFolderPath -branchName $branchName -whatIf $WhatIf

Publish-Changes -checkoutFolder $docsRepoFolderPath -repoFullName $docsRepoFullName -username $GitHubUsername -useremail $GitHubUserEmail -accessToken $GitHubAccessToken -branchName $branchName -fileName "docs/shared-content/samples/samples-instance-features-list.include.md" -whatIf $WhatIf

# 6. Create PR in GitHub on docs repo
$pullRequestBody = "An automated update of the features directory list for the Customer Solutions Team samples instance, https://samples.octopus.app.`n`n
Created by the SamplesDirectory process, run from https://samples-admin.octopus.app"
New-PullRequest -checkoutFolder $docsRepoFolderPath -repoFullName $docsRepoFullName -Title "Updating features directory for samples instance" -Body $pullRequestBody -Head $branchName -Base $docsDefaultBranch -whatIf $WhatIf

# 7. Any clear-up
if (Test-Path -Path $tempCheckoutFolder) {
    Write-Verbose "Clearing up temporary checkout folder $tempCheckoutFolder"
    Remove-Item -Path $tempCheckoutFolder -Recurse -Force 

    Clear-GitHubAuthentication
}

# 8. Profit!