function Clone-Repo {
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

    Set-Location $checkoutFolder
    & git checkout -b $($branchName)
}

function Commit-And-Push-Changes {
    param(
        [string]$checkoutFolder,
        [string]$repoFullName,
        [string]$username,
        [string]$accessToken,
        [string]$branchName,
        [string]$fileName
    )

    Set-Location $checkoutFolder
    
    & git add $fileName
    & git commit -m "Committing changes for samples instance features list markdown."
    & git push -u "https://$($username):$($accessToken)@github.com/$($repoFullName).git" $branchName
}