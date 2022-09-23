# References
# https://qiita.com/PowerBIxyz/items/71b069f4abb2fffd7192
# https://github.com/marclelijveld/Power-BI-Automation/blob/master/PowerBI_RefreshHistoryPerWorkspace.ps1


# Fill in parameters
$groupID = "workspace id" 
$datasetID = "dataset id" 
$RequestBody = @"
{
    "type": "full",
    "commitMode": "transactional",
    "applyRefreshPolicy": "false",
    "objects": [
        {
            "table": "table1",
            "partition": "partition1"
        },
        {
            "table": "table1",
            "partition": "partition2"
        }
    ]
}
"@


# Base API for Power BI REST API
$PbiRestApi = "https://api.powerbi.com/v1.0/myorg/"

# Sign in to the Power BI Service using OAuth
Write-Host -ForegroundColor White "Sign in to connect to the Power BI Service";
Connect-PowerBIServiceAccount

# Check the refresh history
#$GetDatasetRefreshHistory = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes"
#$DatasetRefreshHistory = Invoke-PowerBIRestMethod -Method GET -Url $GetDatasetRefreshHistory | ConvertFrom-Json
#$DatasetRefreshHistory.value

# Refresh tables / partitions
$uri = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes"
Invoke-PowerBIRestMethod -Url $uri –Method POST –Verbose -Body $RequestBody  -ContentType "application/json"