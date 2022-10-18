# References
# https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-history-in-group
# https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-execution-details-in-group
# https://learn.microsoft.com/en-us/power-bi/connect-data/asynchronous-refresh

# Fill in parameters
# ----------------------------------------------------------------------------
$waitTime = 180 # <- how many seconds are we gonna wait between each api call.
$groupID = "Group ID" # <- workspace id
$datasetID = "Dataset ID" # <- dataset id

# Request bodies, must be separated by ","
$RequestBodies = @"
{
    "type": "full",
    "commitMode": "transactional",
    "applyRefreshPolicy": "false",
    "objects": [
        {
            "table": "table1",
            "partition": "partition1"
        }
    ]
}
"@,
@"
{
    "type": "full",
    "commitMode": "transactional",
    "applyRefreshPolicy": "false",
    "objects": [
        {
            "table": "table1",
            "partition": "partition2"
        },
        {
            "table": "table2",
            "partition": "partition1"
        }
    ]
}
"@
# ----------------------------------------------------------------------------

# Base API for Power BI REST API
$PbiRestApi = "https://api.powerbi.com/v1.0/myorg/"

# Sign in to the Power BI Service using OAuth
Write-Host -ForegroundColor White "Sign in to connect to the Power BI Service";
Connect-PowerBIServiceAccount

$iteration = 1
$numerOfRequests = $RequestBodies.Length
$RefreshURL = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes"

# Before starting first refresh, we'll check if there's ongoing refresh. We'll keep looping thourgh until the latest refresh is completed or failed.
Write-Host "Starting checking the latest refresh status."

$retries = 1
DO
{
    # If we send the request not the first time, we'll introduce some delay
    if ( $retries -ne 1 )
    {
        # To not use api each second, we will delay the requests
        Start-Sleep -Seconds $waitTime
    }

    # Get the refresh history of the dataset 
    $DatasetRefreshHistory = Invoke-PowerBIRestMethod -Method GET -Url $RefreshURL | ConvertFrom-Json
    $refreshId = $DatasetRefreshHistory.value[0].requestId
    $requestStatus = $DatasetRefreshHistory.value[0].status

    Write-Host "The latest refresh id: $refreshId, status: $requestStatus."

    $retries++
} Until($requestStatus -ne "Unknown")

# Check if the latest refresh is completed, failed or else
if ($requestStatus -eq "Completed") {
    Write-Host "The latest refresh is completed" -ForegroundColor Green
} elseif ($requestStatus -eq "Failed") {
    Write-Host "The latest refresh has failed" -ForegroundColor Red
} else {
    Write-Host "The latest refresh is unknown??" -ForegroundColor Yellow
}

Write-Host "`n Starting the refresh loop. There will be $numerOfRequests separate refreshes."

# Perform a DO loop until we go through each of the request body from requestBodies array
DO
{
    Write-Host “Starting Loop $iteration”
    
    # Extract a request body from array
    $RequestBody = $RequestBodies[$iteration-1]
    Write-Host “`tStarting Refresh of the specified request body:`n $RequestBody”

    # Refresh the dataset
    Invoke-PowerBIRestMethod -Url $RefreshURL –Method POST –Verbose -Body $RequestBody  -ContentType "application/json"

    # Get the refresh history of the same dataset 
    $DatasetRefreshHistory = Invoke-PowerBIRestMethod -Method GET -Url $RefreshURL | ConvertFrom-Json

    # Retrieve the first refresh id
    $refreshId = $DatasetRefreshHistory.value[0].requestId
    Write-Host "`tRefresh id: $refreshId `n"

    # Url for refresh details of the specified refresh id
    $GetRefreshDetails = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes/" + $refreshId

    # Perform a DO loop until the refresh status is not "Unknown"
    # Keep track of the number of tries
    $retries = 1
    DO
    {
        # To not use api each second, we will delay the requests
        Start-Sleep -Seconds $waitTime

        # Get the refresh details of the specified refresh id
        Write-Host “`t`tStarting checking refresh details. Iteration - $iteration, retry - $retries”
        $RefreshDetails = Invoke-PowerBIRestMethod -Method GET -Url $GetRefreshDetails | ConvertFrom-Json

        # Get the status of the refresh
        $requestStatus = $RefreshDetails.status
        $DateTime = Get-Date
        Write-Host “`t`tDateTime: $DateTime”
        Write-Host "`t`tRefresh status: $requestStatus `n"
        $retries++
    } Until ($requestStatus -ne "Unknown")
    
    # Check if refresh completed, failed or else
    if ($requestStatus -eq "Completed") {
        Write-Host "`tThe refresh is completed" -ForegroundColor Green
    } elseif ($requestStatus -eq "Failed") {
        Write-Host "`tThe refresh has failed" -ForegroundColor Red
    } else {
        Write-Host "`tThe refresh is unknown??" -ForegroundColor Yellow
    }

    $iteration++
} Until ($iteration -eq $numerOfRequests+1)

Write-Host "All refreshes are done."