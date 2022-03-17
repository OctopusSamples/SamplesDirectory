
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
    [string]$markdownSourceFolder,
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
    $exception = $_.Exception
    Write-Error "An error occurred configuring the PowerShellForGitHub PS Module: $($exception.Message)"
    return
}

if (!(Test-Path -Path $markdownSourceFolder)) {
    Write-Error "Markdown folder '$($markdownSourceFolder)' doesnt exist!"
    return
}

$markdownFiles = @(Get-ChildItem -Path $markdownSourceFolder -Filter "*.md")
if ($markdownFiles.Length -lt 1) {
    Write-Error "No markdown files found in folder '$($markdownSourceFolder)'"
    return
}

# Include helpers
. ([System.IO.Path]::Combine($PSScriptRoot, "Git.ps1"))

$docsRepoFullName = "$($docsRepoOrg)/$($docsRepoName)"
$docsDefaultBranch = "master"

if ([string]::IsNullOrWhitespace($branchName)) {
    $branchName = "enh-samplesdirectory-$([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'))"
}

# 1. Checkout the docs repo from git
$tempCheckoutFolder = ([System.IO.Path]::Combine($PSScriptRoot, [System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid()))
$docsRepoFolderPath = ([System.IO.Path]::Combine($tempCheckoutFolder, "docs"))

New-ClonedRepo -checkoutFolder $tempCheckoutFolder -repoFullName $docsRepoFullName -username $GitHubUsername -accessToken $GitHubAccessToken

$ChangesToPublish = $False

# 2. Get each markdown file(s) content
foreach ($markdownFile in $markdownFiles) {
    $markdownFilename = $markdownFile.Name
    $markdownFilePath = $markdownFile.FullName
    $markdownContent = Get-Content $markdownFilePath
    $existingMarkdownFilePath = ([System.IO.Path]::Combine($docsRepoFolderPath, "docs", "shared-content" , "samples", $markdownFile))

    # 3. Does existing file exist?
    if (!(Test-Path -Path $existingMarkDownFilePath)) {
        Write-Host "No file exists at: $existingMarkDownFilePath. This most-likely indicates it's a new file"
        
        # 3.1 Copy the contents of the new file to designated location
        Set-Content -Path $existingMarkDownFilePath -Value $markdownContent
        $ChangesToPublish = $True
    }
    else {
        # 3.2.1 Check to see if existing file contents are the same as new. If they are, nothing to do for this file
        $existingMarkdownContent = Get-Content -Path $existingMarkDownFilePath
        $existingMarkdownTempFile = New-TemporaryFile
        
        # 3.2.2 We write out the content from the Git repo to a temp file, to workaround LF -> CRLF issues.
        Write-Verbose "Writing existing markdown file to $existingMarkdownTempFile to test file hashes"
        Set-Content -Path $existingMarkdownTempFile -Value $existingMarkdownContent
        
        # 3.2.3 Calculate hashes of both files
        $existingMarkDownFileHash = Get-FileHash -Path $existingMarkdownTempFile
        $newMarkDownFileHash = Get-FileHash -Path $markdownFilePath

        Write-Verbose "Existing '$markdownFilename' FileHash: $($existingMarkDownFileHash.Hash)"
        Write-Verbose "New file '$markdownFilename' FileHash: $($newMarkDownFileHash.Hash)"
        
        # 3.2.4 Compare hashes and continue if nothing to do
        if ($existingMarkDownFileHash.Hash -ieq $newMarkDownFileHash.Hash) {
            Write-Host "New content file hash for '$markdownFilename' matches existing content file hash. Nothing to update"
            continue;
        }
        else {
            Set-Content -Path $existingMarkDownFilePath -Value $markdownContent
            $ChangesToPublish = $True
        }
    }
}

# 4. Check for any file changes
if ($ChangesToPublish -eq $False) {
    Write-Host "All content file hashes match existing content file hashes. Completing"
}
else {

    Write-Host "WhatIf set to $WhatIf."

    # 5. Create new branch and commit file
    New-Branch -checkoutFolder $docsRepoFolderPath -branchName $branchName -whatIf $WhatIf

    Publish-Changes -checkoutFolder $docsRepoFolderPath -repoFullName $docsRepoFullName -username $GitHubUsername -useremail $GitHubUserEmail -accessToken $GitHubAccessToken -branchName $branchName -fileName "docs/shared-content/samples/samples-instance-features-list.include.md" -whatIf $WhatIf

    # 6. Create PR in GitHub on docs repo
    $pullRequestBody = "An automated update of the features directory list for the Customer Solutions Team samples instance, https://samples.octopus.app.`n`n
Created by the SamplesDirectory process, run from https://samples-admin.octopus.app"
    New-PullRequest -checkoutFolder $docsRepoFolderPath -repoFullName $docsRepoFullName -Title "Updating features directory for samples instance" -Body $pullRequestBody -Head $branchName -Base $docsDefaultBranch -whatIf $WhatIf
}

# 7. Any clear-up
if (Test-Path -Path $tempCheckoutFolder) {
    Write-Verbose "Clearing up temporary checkout folder $tempCheckoutFolder"
    Remove-Item -Path $tempCheckoutFolder -Recurse -Force 

    Clear-GitHubAuthentication
}

# 8. Profit!