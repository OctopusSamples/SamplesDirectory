
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
    [string]$branchName
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

if (!(Test-Path -Path $markDownFilePath)) {
    Write-Error "Markdown file at $($markDownFilePath) doesnt exist!"
    return
}

# Include helpers
. ([System.IO.Path]::Combine($PSScriptRoot, "Git.ps1"))

$docsRepoFullName = "$($docsRepoOrg)/$($docsRepoName)"
if ([string]::IsNullOrWhitespace($branchName)) {
    $branchName = "enh-samplesdirectory-$([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'))"
}

# 1. Get the markdown file from the artifact stored in the runbook execution
$markdownContent = Get-Content $markDownFilePath

# 2. Checkout the docs repo from git
$tempCheckoutFolder = ([System.IO.Path]::Combine($PSScriptRoot, [System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid()))
$docsFolderPath = ([System.IO.Path]::Combine($tempCheckoutFolder, "docs"))

Clone-Repo -checkoutFolder $tempCheckoutFolder -repoFullName $docsRepoFullName -username $GitHubUsername -accessToken $GitHubAccessToken

# 3. Check to see if file contents are the same. If they are, nothing to do
$existingMarkDownFilePath = ([System.IO.Path]::Combine($docsFolderPath, "docs", "shared-content" , "samples", "samples-instance-features-list.include.md"))
$existingMarkDownFileHash = Get-FileHash -Path $existingMarkDownFilePath
$newMarkDownFileHash = Get-FileHash -Path $markDownFilePath

Write-Verbose "Existing samples-instance-features-list.include.md FileHash: $($existingMarkDownFileHash.Hash)"
Write-Verbose "New content for features-list FileHash: $($newMarkDownFileHash.Hash)"

if ($existingMarkDownFileHash.Hash -ieq $newMarkDownFileHash.Hash) {
    Write-Host "New content file hash matches existing content file hash. Nothing to update"
    return;
}

# 4. Copy the contents to designated location (probably somewhere where the include files live)
Set-Content -Path $existingMarkDownFilePath -Value $markdownContent

# 5. Create new branch and commit file
New-Branch -checkoutFolder $tempCheckoutFolder -branchName $branchName
Publish-Changes -checkoutFolder $tempCheckoutFolder -repoFullName $docsRepoFullName -username $GitHubUsername -accessToken $GitHubAccessToken -branchName "test-gh-pr" -fileName "docs/shared-content/samples/samples-instance-features-list.include.md"

# 6. Create PR in GitHub on docs repo


# 7. Any clear-up
if (Test-Path -Path $tempCheckoutFolder) {
    Write-Verbose "Clearing up temporary checkout folder $tempCheckoutFolder"
    Remove-Item -Path $tempCheckoutFolder -Recurse -Force 
}

# 8. Profit!