function New-ClonedRepo {
    param(
        [string]$checkoutFolder,
        [string]$repoFullName,
        [string]$username,
        [string]$accessToken
    )
    $prevLocation = Get-Location
    Write-Output "Cloning repository '$($repoFullName)' to: $($checkoutFolder)"
    
    try {
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
        Set-Location $prevLocation
    }
}

function New-Branch {
    param (
        [string]$checkoutFolder,
        [string]$branchName
    )
    $prevLocation = Get-Location
    try {
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

function Publish-Changes {
    param(
        [string]$checkoutFolder,
        [string]$repoFullName,
        [string]$username,
        [string]$accessToken,
        [string]$branchName,
        [string]$fileName
    )
    $prevLocation = Get-Location
    try {

        Set-Location $checkoutFolder
    
        & git add $fileName
        if ($LASTEXITCODE -ne 0) {
            throw "Error adding $fileName to branch: $branchName"       
        }
        & git commit -m "Updating samples-instance-features-list.include.md with new directory contents"
        if ($LASTEXITCODE -ne 0) {
            throw "Error committing changes for $fileName to branch: $branchName"
        }
        & git push -u "https://$($username):$($accessToken)@github.com/$($repoFullName).git" $branchName
        if ($LASTEXITCODE -ne 0) {
            throw "Error pushing changes for $fileName to branch: $branchName to $repoFullName"
        }
    }
    finally {
        Set-Location $prevLocation
    }
}