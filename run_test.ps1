$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$env:PYTHONPATH="Backend"

if (!(Test-Path -Path "Reports")) {
    New-Item -ItemType Directory -Path "Reports"
}

pytest Tests/ --junitxml="Reports/report-$timestamp.xml" |
    Tee-Object -FilePath "Reports/test-report-$timestamp.txt"
