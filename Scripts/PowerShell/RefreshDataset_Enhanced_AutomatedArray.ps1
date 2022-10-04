# Fill in parameters
$groupID = "Group ID" 
$datasetID = "Dataset ID" 
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


# Base API for Power BI REST API
$PbiRestApi = "https://api.powerbi.com/v1.0/myorg/"

# Sign in to the Power BI Service using OAuth
Write-Host -ForegroundColor White "Sign in to connect to the Power BI Service";
Connect-PowerBIServiceAccount


$iteration = 1
$GetDatasetRefreshHistory = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes"

# Perform a DO loop until we go through each of the request body from requestBodies array
DO
{
    Write-Host “Starting Loop $iteration”
    
    # Extract a request body from array
    $RequestBody = $RequestBodies[$iteration-1]
    Write-Host “Starting Refresh of the specified request body:`n $RequestBody”

    # Refresh the dataset
    Invoke-PowerBIRestMethod -Url $uri –Method POST –Verbose -Body $RequestBody  -ContentType "application/json"

    # Get the refresh history of the same dataset 
    $DatasetRefreshHistory = Invoke-PowerBIRestMethod -Method GET -Url $GetDatasetRefreshHistory | ConvertFrom-Json

    # Retrieve the first refresh id
    $refreshId = $DatasetRefreshHistory.value[0].requestId
    Write-Host "Refresh id: $refreshId `n"

    # Url for refresh details of the specified refresh id
    $GetRefreshDetails = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes/" + $refreshId

    # Perform a DO loop until the refresh status is not "Unknown"
    DO
    {
        # Keep track of the number of tries
        $retries = 1

        # To not use api each second, we will delay the requests
        Start-Sleep -Seconds 2

        # Get the refresh details of the specified refresh id
        Write-Host “Starting checking refresh details. Iteration - $iteration, retry - $retries”
        $RefreshDetails = Invoke-PowerBIRestMethod -Method GET -Url $GetRefreshDetails | ConvertFrom-Json

        # Get the status of the refresh
        $requestStatus = $RefreshDetails.status
        $DateTime = Get-Date
        Write-Host “DateTime: $DateTime”
        Write-Host "Refresh status: $requestStatus `n"
        $retries++
    } Until ($requestStatus -ne "Unknown")
    
    # Check if refresh completed, failed or else
    if ($requestStatus -eq "Completed") {
        Write-Host "The refresh is completed" -ForegroundColor Green
    } elseif ($requestStatus -eq "Failed") {
        Write-Host "The refresh has failed" -ForegroundColor Red
    } else {
        Write-Host "The refresh is unknown??" -ForegroundColor Yellow
    }

    $iteration++
} Until ($iteration -eq $RequestBodies.Length+1)
