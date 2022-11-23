# References
# https://blog.crossjoin.co.uk/2022/06/19/cancelling-power-bi-dataset-refreshes-with-the-enhanced-refresh-api/
# Limitations - https://learn.microsoft.com/en-us/power-bi/connect-data/asynchronous-refresh#non-enhanced-refresh-operations

# Fill in parameters
# ----------------------------------------------------------------------------
$groupID = "Group ID" # <- workspace id
$datasetID = "Dataset ID" # <- dataset id
$requestID = "" # <- refresh id which will be canceled, leave empty to cancel latest refresh
# ----------------------------------------------------------------------------

# Installs or updates the the PowerShell Power BI Cmdlets.
# Requires admin privileges to find module!
# ----------------------------------------------------------------------------
$localModule = Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable -ErrorAction SilentlyContinue
$remoteModule = Find-Module -Name MicrosoftPowerBIMgmt -Repository PSGallery

if ($remoteModule.Version -ne ($localModule.Version | Measure-Object -Maximum).Maximum ) {
    Install-Module -Name MicrosoftPowerBIMgmt -Repository PSGallery -Scope CurrentUser -SkipPublisherCheck -Force
}
else {
    $localModule
}
# ----------------------------------------------------------------------------

# Base API for Power BI REST API
$PbiRestApi = "https://api.powerbi.com/v1.0/myorg/"

# Sign in to the Power BI Service using OAuth
Write-Host -ForegroundColor White "Sign in to connect to the Power BI Service";
Connect-PowerBIServiceAccount

if ( $requestID -eq "" ) {
    
    # Get the latest refresh
    $refreshURL = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes"
    $latestDatasetRefresh = Invoke-PowerBIRestMethod -Method GET -Url "$($refreshURL)?`$top=1" | ConvertFrom-Json
    $latestRefreshType = $latestDatasetRefresh.value.refreshType

    if ( ( $latestRefreshType -eq "OnDemand" ) -or ( $latestRefreshType -eq "Scheduled" ) ) {
        throw "The latest refresh type is " + $latestRefreshType + ". Scheduled and on-demand (manual) dataset refreshes " +
        "can't be canceled by using DELETE /refreshes/<requestId>." +
        "More information - https://learn.microsoft.com/en-us/power-bi/connect-data/asynchronous-refresh#non-enhanced-refresh-operations"
    } else {
        $requestId = $latestDatasetRefresh.value.requestId
    }
}

# Url for refresh details of the specified refresh id
$refreshIDurl = $PbiRestApi + "groups/" + $groupID + "/datasets/" + $datasetID + "/refreshes/" + $requestId

$body = Invoke-PowerBIRestMethod -Method Get -Url $refreshIDurl | ConvertFrom-Json
$body | Select-Object * -ExcludeProperty "objects"
$body.objects | Where-Object -Property status -NE "Completed"

Invoke-PowerBIRestMethod -Url $refreshIDurl -Method Delete