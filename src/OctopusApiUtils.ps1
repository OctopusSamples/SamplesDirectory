function Get-OctopusUrl {
    param (
        $EndPoint,
        $SpaceId,
        $OctopusUrl
    )

    $octopusUrlToUse = $OctopusUrl
    if ($OctopusUrl.EndsWith("/")) {
        $octopusUrlToUse = $OctopusUrl.Substring(0, $OctopusUrl.Length - 1)
    }

    if ($EndPoint -match "/api") {
        if (!$EndPoint.StartsWith("/api")) {
            $EndPoint = $EndPoint.Substring($EndPoint.IndexOf("/api"))
        }

        return "$octopusUrlToUse$EndPoint"
    }

    if ([string]::IsNullOrWhiteSpace($SpaceId)) {
        return "$octopusUrlToUse/api/$EndPoint"
    }

    return "$octopusUrlToUse/api/$spaceId/$EndPoint"
}

function Invoke-OctopusApi {
    param
    (
        $url,
        $apiKey,
        $method,
        $item,
        $filePath,
        $retryCount
    )

    try {
        if ($null -ne $filePath) {
            Write-OctopusVerbose "Filepath $filePath parameter provided, saving output to the filepath from $url"
            return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -OutFile $filePath -TimeoutSec 60
        }

        if ($null -eq $item) {
            Write-OctopusVerbose "Calling invoke-restmethod for $url"
            return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -ContentType 'application/json; charset=utf-8' -TimeoutSec 60
        }

        $body = $item | ConvertTo-Json -Depth 10
        Write-OctopusVerbose $body

        Write-OctopusVerbose "Invoking $method $url"
        return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -Body $body -ContentType 'application/json; charset=utf-8' -TimeoutSec 60
    }
    catch [System.TimeoutException] {        
        $newRetryCount = 1
        if ($null -ne $retryCount) {
            $newRetryCount = $retryCount + 1
        }

        if ($newRetryCount -gt 4) {
            Throw "Timeout detected, max retries has been exceeded for this call.  Exiting."
        }
        else {
            Write-OctopusWarning "Timeout detected, going to retry this call for the $newRetryCount time."
            Invoke-OctopusApi -url $url -apiKey $apiKey -method $method -item $item -filePath $filePath -retryCount $retryCount        
        }
    }
    catch {
        Write-OctopusCritical "There was an error making a $method call to $url.  All request information (JSON body specifically) is stored in the log.  Please check that for more information."

        if ($null -ne $_.Exception.Response) {
            if ($_.Exception.Response.StatusCode -eq 401) {
                Write-OctopusCritical "Unauthorized error returned from $url, please verify API key and try again"
            }
            elseif ($_.ErrorDetails.Message) {                
                Write-OctopusCritical -Message "Error calling $url StatusCode: $($_.Exception.Response) $($_.ErrorDetails.Message)"
                Write-OctopusCritical $_.Exception
            }            
            else {
                Write-OctopusCritical $_.Exception
            }
        }
        else {
            Write-OctopusCritical $_.Exception
        }

        Write-OctopusCritical "Exiting the Catalog processor."
        Exit 1
    }    
}

Function Get-OctopusApiItemList {
    param (
        $EndPoint,
        $ApiKey,
        $SpaceId,
        $OctopusUrl
    )

    $url = Get-OctopusUrl -EndPoint $EndPoint -SpaceId $SpaceId -OctopusUrl $OctopusUrl

    $results = Invoke-OctopusApi -Method "Get" -Url $url -apiKey $ApiKey

    Write-OctopusVerbose "$url returned a list with $($results.Items.Length) item(s)"

    if ($results.Items.Count -eq 0) {
        return @()
    }

    return $results.Items
}

Function Get-OctopusApi {
    param (
        $EndPoint,
        $ApiKey,
        $SpaceId,
        $OctopusUrl
    )

    $url = Get-OctopusUrl -EndPoint $EndPoint -SpaceId $SpaceId -OctopusUrl $OctopusUrl

    $results = Invoke-OctopusApi -Method "Get" -Url $url -apiKey $ApiKey

    return $results
}