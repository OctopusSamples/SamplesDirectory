$currentDate = Get-Date
$currentDateFormatted = $currentDate.ToString("yyyy_MM_dd_HH_mm_ss")
$catalogVersion = "0.0.1"

$logFolder = "$PSScriptRoot"
$logArchiveFolder = "$PSScriptRoot/logs/archive__$currentDateFormatted" 

$logPath = [System.IO.Path]::Combine($logFolder, "log.txt")
$archiveLogs = $False

$RunningWithinOctopus = ($null -ne $OctopusParameters)
if ($RunningWithinOctopus -eq $True -and $PSEdition -eq "Core") {
    $PSStyle.OutputRendering = "PlainText"
}

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

    Write-Host $message -ForegroundColor Green
    Write-OctopusLog $message    
}

function Write-OctopusWarning {
    param($message)

    Write-Host "Warning $message" -ForegroundColor Yellow    
    Write-OctopusLog $message
}

function Write-OctopusCritical {
    param ($message)

    Write-Host "Critical Message: $message" -ForegroundColor Red
    Write-OctopusLog $message
}

function Write-OctopusLog {
    param ($message)

    Add-Content -Value $message -Path $logPath
}

function Write-OctopusHighlight {
    param ($message)
    try {
        Get-Command 'Write-Highlight' 
        Write-Highlight $message
    }
    catch{
        Write-Output $message
        Write-OctopusLog $message
    }
}

Write-Host "Using version $catalogVersion of the catalog processor."
