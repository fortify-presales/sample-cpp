#
# Example script to perform Fortify ScanCentral SAST scan
#

# Import some supporting functions
Import-Module $PSScriptRoot\modules\FortifyFunctions.psm1

# Import local environment specific settings
$EnvSettings = $(ConvertFrom-StringData -StringData (Get-Content (Join-Path "." -ChildPath ".env") | Where-Object {-not ($_.StartsWith('#'))} | Out-String))
$AppName = $EnvSettings['SSC_APP_NAME']
$AppVersion = $EnvSettings['SSC_APP_VER_NAME']
$SSCAuthToken = $EnvSettings['SSC_AUTH_TOKEN'] # CIToken
$ScanCentralCtrlUrl = $EnvSettings['SCANCENTRAL_CTRL_URL']
$ScanCentralPoolId = $EnvSettings['SCANCENTRAL_POOL_ID'] # Not yet used
$ScanCentralEmail = $EnvSettings['SCANCENTRAL_EMAIL']

$ScanSwitches = ""
$PackageName = "Package.zip"

# Test we have Fortify installed successfully
Test-Environment
if ([string]::IsNullOrEmpty($ScanCentralCtrlUrl)) { throw "ScanCentral Controller URL has not been set" }
if ([string]::IsNullOrEmpty($ScanCentralEmail)) { throw "ScanCentral Email has not been set" }
if ([string]::IsNullOrEmpty($SSCAuthToken)) { throw "SSC Authentication token has not been set" }
if ([string]::IsNullOrEmpty($AppName)) { throw "Application Name has not been set" }
if ([string]::IsNullOrEmpty($AppVersion)) { throw "Application Version has not been set" }

# Delete Package if it already exists
if (Test-Path $PackageName) {
   Remove-Item $PackageName -Verbose
}

# Package, upload and run the scan and import results into SSC
Write-Host Invoking ScanCentral SAST ...
Write-Host "scancentral -url $ScanCentralCtrlUrl start -upload -uptoken $SSCAuthToken -sp $PackageName -b $AppName -application $AppName -version $AppVersion -bt msbuild -bf ALL_BUILD.vcxproj -email $ScanCentralEmail -block -o -f $($AppName).fpr"
& scancentral -url $ScanCentralCtrlUrl start -upload -uptoken $SSCAuthToken -sp $PackageName `
    -b $AppName -application $AppName -version $AppVersion -bt msbuild -bf ALL_BUILD.vcxproj `
    -email $ScanCentralEmail -block -o -f "$($AppName).fpr" 

# Summarise issue count by analyzer
if ($SCALocalInstall -eq $True) {
    & fprutility -information -analyzerIssueCounts -project "$($AppName).fpr"
    Write-Host Generating PDF report...
    & ReportGenerator '-Dcom.fortify.sca.ProjectRoot=.fortify' -user "Demo User" -format pdf -f "$($AppName).pdf" -source "$($AppName).fpr"
}

# Uncomment if not using "-block" in scancentral command above
#Write-Host
#Write-Host You can check ongoing status with:
#Write-Host " scancentral -url $ScanCentralCtrlUrl status -token [received-token]"
