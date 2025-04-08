# Define variables
$mirrorUrl = "https://cdn.mysql.com/Downloads/Connector-ODBC/9.2/mysql-connector-odbc-9.2.0-winx64.msi"
$downloadPath = "$env:TEMP\mysql-connector-odbc-9.2.0-winx64.msi"

# Create WebClient and set headers
$webClient = New-Object System.Net.WebClient
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

try {
    Write-Host "Downloading MySQL ODBC driver..."
    $webClient.DownloadFile($mirrorUrl, $downloadPath)
    Write-Host "Download completed: $downloadPath"
}
catch {
    Write-Error "Failed to download the file: $_"
    exit 1
}

# Verify file exists before attempting install
if (Test-Path $downloadPath) {
    try {
        Write-Host "Starting installation..."
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" /qn" -Wait -PassThru

        if ($process.ExitCode -eq 0) {
            Write-Host "Installation completed successfully."
        } else {
            Write-Error "Installer exited with code $($process.ExitCode)"
            exit $process.ExitCode
        }
    }
    catch {
        Write-Error "Installation failed: $_"
        exit 1
    }
} else {
    Write-Error "Downloaded file not found at $downloadPath"
    exit 1
}

# Link to SQL Server

# Path variable to T-SQL script for linked server creation
$sqlScriptPath = "F:\PowerShell\add-linked-server.sql" 

# Check if SQL script exists
if (-Not (Test-Path $sqlScriptPath)) {
    Write-Error "SQL script not found at: $sqlScriptPath"
    exit 1
}

# Check if Invoke-SqlCmd is available
if (-Not (Get-Command Invoke-SqlCmd -ErrorAction SilentlyContinue)) {
    Write-Error "Invoke-SqlCmd is not available. Ensure the SqlServer module is installed."
    exit 1
}

# Try to execute the SQL script
try {
    $connString = 'Server=.\MSSQLSERVER2019;Database=master;User ID=sa;Password=sap'
    Write-Host "Executing linked server script..."
    Invoke-SqlCmd -ConnectionString $connString -InputFile $sqlScriptPath -ErrorAction Stop
    Write-Host "Linked server created successfully."
}
catch {
    Write-Error "Creation of linked server failed: $_"
    exit 1
}
