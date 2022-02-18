
function Write-OctopusHighlight {
    param ($message)
    try {
        Get-Command 'Write-Highlight' | Out-Null
        Write-Highlight $message
    }
    catch {
        Write-Output $message
    }
}

function New-ClonedRepo {
    param(
        [string]$checkoutFolder,
        [string]$repoFullName,
        [string]$username,
        [string]$accessToken
    )
    $prevLocation = Get-Location

    try {
        Write-Output "##octopus[stderr-progress]"
        Write-Output "Cloning repository '$($repoFullName)' to: $($checkoutFolder)"
        if (!(Test-Path -Path $checkoutFolder)) {
            Write-Verbose "Creating working directory: $checkoutFolder"
            New-Item -ItemType "Directory" -Path $checkoutFolder
        }
        Write-Verbose "Changing working directory to: $checkoutFolder"
        Set-Location $checkoutFolder
        & git clone "https://$($username):$($accessToken)@github.com/$($repoFullName).git"
        if ($LASTEXITCODE -ne 0) {
            throw "Error running git clone of repository $($repoFullName)"       
        }
    }
    catch {
        throw "Error cloning git repository '$($repoFullName)' - $($_.Message)"       
    }
    finally {
        Write-Output "##octopus[stderr-default]"
        Set-Location $prevLocation
    }
}

function New-Branch {
    param (
        [string]$checkoutFolder,
        [string]$branchName,
        [bool]$WhatIf
    )
    $prevLocation = Get-Location
    
    if ($WhatIf -eq $True) {
        Write-OctopusHighlight "WhatIf: Would have created a new branch called $branchName"
    }
    else {
    

        try {
            Write-Output "Creating branch $branchName"
            Set-Location $checkoutFolder
            & git checkout -b $($branchName)
            if ($LASTEXITCODE -ne 0) {
                throw "Error checking out branch $branchName"
            }
        }
        finally {
            Set-Location $prevLocation
        }
    }
}

function Publish-Changes {
    param(
        [string]$checkoutFolder,
        [string]$repoFullName,
        [string]$username,
        [string]$useremail,
        [string]$accessToken,
        [string]$branchName,
        [string]$fileName,
        [bool]$WhatIf
    )
    $prevLocation = Get-Location

    if ($WhatIf -eq $True) {
        Write-OctopusHighlight "WhatIf: Would have added and committed '$fileName' to branch $branchName."
    }
    else {
        try {
            Write-Output "Publishing changes to file $fileName to $repoFullName in branch $branchName."
            Set-Location $checkoutFolder

            Write-Verbose "Running git config for user.email"
            & git config user.email $useremail
            if ($LASTEXITCODE -ne 0) {
                throw "Error running git config for user.email"       
            }

            Write-Verbose "Running git config for user.name"
            & git config user.name $username
            if ($LASTEXITCODE -ne 0) {
                throw "Error running git config for user.name"       
            }

            Write-Verbose "Adding file $fileName to branch $branchName"
            & git add $fileName
            if ($LASTEXITCODE -ne 0) {
                throw "Error adding $fileName to branch: $branchName"       
            }
        
            Write-Verbose "Committing file $fileName"
            & git commit -m "Updating samples-instance-features-list.include.md with new directory contents"
            if ($LASTEXITCODE -ne 0) {
                throw "Error committing changes for $fileName to branch: $branchName"
            }

            Write-Verbose "Pushing file $fileName changes to $branchName"
            & git push -u "https://$($username):$($accessToken)@github.com/$($repoFullName).git" $branchName
            if ($LASTEXITCODE -ne 0) {
                throw "Error pushing changes for $fileName to $repoFullName in $branchName"
            }
        }
        finally {
            Set-Location $prevLocation
        }
    }
}

function New-PullRequest {
    param(
        [string]$checkoutFolder,
        [string]$repoFullName,
        [string]$Title,
        [string]$Body,
        [string]$Head,
        [string]$Base,
        [bool]$WhatIf
    )
    $prevLocation = Get-Location

    if ($WhatIf -eq $True) {
        Write-OctopusHighlight "WhatIf: Would have created a pull request for $Head -> $Base"
    }
    else {
        try {
            Write-Output "Creating a pull request to $repoFullName for $head -> $base"
            Set-Location $checkoutFolder

            $prParams = @{
                Uri                 = "https://github.com/$repoFullName"
                Title               = $Title
                Head                = $Head
                Base                = $Base
                Body                = $Body
                MaintainerCanModify = $true
            }
            $pullRequest = New-GitHubPullRequest @prParams
            Write-OctopusHighlight "PR #$($pullRequest.number) created - $($pullRequest.html_url)"
            Write-Verbose $pullRequest
        }
        finally {
            Set-Location $prevLocation
        }
    }
}