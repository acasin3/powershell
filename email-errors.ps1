Import-Module SqlServer

function GenerateErrorsTodayReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$sqlServer,

        [Parameter(Mandatory)]
        [string]$dbName
    )

    $head = @"
        <style>
        body {font-family:'Segoe UI', Arial}
        table { border-collapse: collapse; width: 100%; }
        th { background-color: #4CAF50; color: white; text-align: left; padding: 8px; }
        td { border: 1px solid #ddd; padding: 8px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        tr:hover { background-color: #ddd; }
        </style>
        <h1>Database Errors</h1>
"@

    $outFile = "$env:temp\errors_$(Get-Date -Format FileDate).html"

    $connString = "SERVER=$sqlServer; DATABASE=$dbName;Integrated Security=True;"
    $sql = "SELECT * FROM vwErrorsToday ORDER BY Time_Stamp DESC"

    $errors = Invoke-Sqlcmd -ConnectionString $connString `
                            -Query $sql

    if ($errors.Count -eq 0 ) {
        $data = @"
<html>
<head>
    <title>Database Errors</title>
</head>
<body>
    <p>No errors today.</p>
</body>
</html>
"@
    } else {
        $data = $errors `
            | Select-Object @{Name="Message"; Expression = {$_.ErrorMessage}}, `
                            @{Name="Severity"; Expression = {$_.ErrorSeverity}}, `
                            @{Name="State"; Expression = {$_.ErrorState}}, `
                            @{Name="Routine"; Expression = {$_.ErrorRoutine}}, `
                            @{Name="Line No"; Expression = {$_.ErrorLine}}, `
                            @{Name="User Name"; Expression = {$_.UserName}}, `
                            @{Name="Host Name"; Expression = {$_.HostName}}, `
                            @{Name="TimeStamp"; Expression = {$_.Time_Stamp}} `
            | ConvertTo-HTML -Head $head
    }

    Set-Content -Path $outFile -Value $data -Force

    return $outFile
}


