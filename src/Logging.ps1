$currentDate = Get-Date
$currentDateFormatted = $currentDate.ToString("yyyy_MM_dd_HH_mm_ss")
$catalogVersion = "0.0.1"

$logFolder = "$PSScriptRoot"
$logArchiveFolder = "$PSScriptRoot/logs/archive__$currentDateFormatted" 

$logPath = [System.IO.Path]::Combine($logFolder, "log.txt")
$archiveLogs = $False

$RunningWithinOctopus = ($null -ne $OctopusParameters)
Write-Host "RunningWithinOctopus: $RunningWithinOctopus"

if (Test-Path $logPath) {

    if ($archiveLogs -eq $True) {
        if ((Test-Path -Path $logArchiveFolder) -eq $false) {
            New-Item -Path $logArchiveFolder -ItemType Directory
        }
        Get-ChildItem -Path "$logFolder*.txt" | Move-Item -Destination $logArchiveFolder
    }
    else {
        # just blank the log file out
        Set-Content -Path  $logPath -Value ""
    }   
}

function Get-OctopusLogPath {
    return $logPath
}

function Write-OctopusVerbose {
    param($message) 
       
    Write-Verbose $message    
    Write-OctopusLog $message
}

function Write-OctopusSuccess {
    param($message)

    $params = @{
        Object = $message;
    }
    if($RunningWithinOctopus -eq $False) {
        $params.ForegroundColor = "Green";
    }

    Write-Host @params
    Write-OctopusLog $message    
}

function Write-OctopusWarning {
    param($message)

    $params = @{
        Object = "Warning: $message";
    }
    if($RunningWithinOctopus -eq $False) {
        $params.ForegroundColor = "Yellow";
    }

    Write-Host @params
    Write-OctopusLog $message
}

function Write-OctopusCritical {
    param ($message)

    $params = @{
        Object = "Critical Message: $message";
    }
    if($RunningWithinOctopus -eq $False) {
        $params.ForegroundColor = "Red";
    }

    Write-Host @params
    Write-OctopusLog $message
}

function Write-OctopusLog {
    param ($message)

    Add-Content -Value $message -Path $logPath
}

Write-Host "Using version $catalogVersion of the catalog processor."
