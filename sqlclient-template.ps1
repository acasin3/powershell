Import-Module SqlServer

try {
    $connString = "SERVER=.\MSSQLSERVER2019;DATABASE=master;User ID=sa; Password=sap"
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = $connString
    $conn.Open()
    
    Write-Host "Connection established successfully." -ForegroundColor Green
}
catch [System.Data.SqlClient.SqlException]
{
    # SQL-specific error handling
    $exception = $_.Exception

    # Logging the error with details
    $errorMessage = "SQL Exception: $($exception.Message)"
    $errorCode = "Error Code: $($exception.Number)"
    $errorSeverity = "Severity: $($exception.Class)"
    $errorState = "State: $($exception.State)"
    $stackTrace = "Stack Trace: $($exception.StackTrace)"

    # Print the error message to console
    Write-Host $errorMessage -ForegroundColor Red
    Write-Host $errorCode -ForegroundColor Red
    Write-Host $errorSeverity -ForegroundColor Red
    Write-Host $errorState -ForegroundColor Red
    Write-Host $stackTrace -ForegroundColor Red

    # Optionally, log the error to a file
    $logPath = "error_log.txt"
    $logEntry = "$(Get-Date) - $errorMessage`n$errorCode`n$errorSeverity`n$errorState`n$stackTrace`n"
    Add-Content -Path $logPath -Value $logEntry

    # Optionally, rethrow the error or handle recovery
    # Throw $_.Exception  # Uncomment this to stop the script on failure

}
catch
{
    # General error handling for unexpected issues
    $exception = $_.Exception

    # Logging the general error
    $errorMessage = "Unexpected error: $($exception.Message)"
    $stackTrace = "Stack Trace: $($exception.StackTrace)"
    Write-Host $errorMessage -ForegroundColor Yellow
    Write-Host $stackTrace -ForegroundColor Yellow

    # Optionally, log the error to a file
    $logPath = "error_log.txt"
    $logEntry = "$(Get-Date) - $errorMessage`n$stackTrace`n"
    Add-Content -Path $logPath -Value $logEntry

    # Consider if you want to rethrow or handle differently
    # Throw $_.Exception  # Uncomment this to stop on error
}
finally
{
    # Ensure cleanup or closing operations if needed
    if ($conn.State -eq 'Open') {
        $conn.Close()
        Write-Host "Connection closed." -ForegroundColor Green
    }
}
