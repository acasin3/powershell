# Import the SqlServer module with error handling
try {
    Import-Module SqlServer -ErrorAction Stop
    Write-Host "SqlServer module loaded successfully."
}
catch {
    Write-Error "Failed to import SqlServer module: $_"
    exit 1  # Exit if the module is critical to your script's functionality
}

function Start-Download {
    param (
        [Parameter(Mandatory)]
        [string]$DownloadUrl,

        [Parameter()]
        [string]$DownloadMessage = ''
    )

    # Define variables
    $saveAsFileName = $DownloadUrl | Split-Path -Leaf
    $downloadPath = "$env:TEMP\$saveAsFileName"

    # Create WebClient and set headers
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

    try {
        # In case download message ends with an ellisis, remove it.
        $DownloadMessage = $DownloadMessage.TrimEnd('...')

        if ($DownloadMessage -ne '') {
            # Add ellipsis
            Write-Host ($DownloadMessage + '...')
        } else {
            Write-Host 'Downloading file...'
        }

        $webClient.DownloadFile($DownloadUrl, $downloadPath)
        Write-Host "Download completed: $downloadPath"

        # Output the full path of the downloaded file so it can be "piped" to the next command
        return $downloadPath
    }
    catch {
        Write-Error "Failed to download the file: $_"
        exit 1
    }
}

function Install-MySqlOdbc {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
        ]
        [AllowEmptyString()]
        [string]$installerPath
    )

    process {
        if (Test-Path $installerPath) {
            try {
	            Write-Host "Starting installation..."
	            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /qn" -Wait -PassThru

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
            Write-Error "Installer not found at $downloadPath"
	        exit 1
	    }
	}
}

function Test-OdbcDsnExists {
    param (
        [Parameter(Mandatory)]
        [string]$DsnName,

        [Parameter()]
        [ValidateSet("System", "User")]
        [string]$DsnType = "System"
    )

    try {
        $arch = if ([Environment]::Is64BitProcess) { "64" } else { "32" }
        $basePath = if ($DsnType -eq "System") {
            if ($arch -eq "32") {
                "HKLM:\SOFTWARE\WOW6432Node\ODBC\ODBC.INI\$DsnName"
            } else {
                "HKLM:\SOFTWARE\ODBC\ODBC.INI\$DsnName"
            }
        } else {
            "HKCU:\SOFTWARE\ODBC\ODBC.INI\$DsnName"  # User DSNs are the same for 32/64-bit
        }

        return Test-Path $basePath
    }
    catch {
        Write-Error "Error checking ODBC DSN: $_"
        return $false
    }
}

function Add-MySqlOdbcDsn {
    param (
        [Parameter(Mandatory)]
        [string]$DsnName,

        [Parameter(Mandatory)]
        [string]$DriverName,

        [Parameter()]
        [string]$Description = "",

        [ValidateSet("System", "User")]
        [string]$DsnType = "System",

        [Parameter(Mandatory)]
        [string]$DbServerUserId,

        [Parameter(Mandatory)]
        [string]$DbServerPwd,

        [switch]$Force
    )

    # Try to add MySQL ODBC. To get driver name, try adding a driver through the UI and check the name.
    $exists = Test-OdbcDsnExists -DsnName $DsnName -DsnType $DsnType

    if ($exists -and $Force) {
        try {
            Remove-OdbcDsn -Name $DsnName -DsnType $DsnType
            # Now that the ODBC has been remove, update the $exists flag.
            $exists = $false
        }
        catch {
            Write-Error "Failed to remove DSN '$DsnName': $_"
            exit 1
        }
    }

    if (-not $exists) {
        try {
            Add-OdbcDsn -Name $DsnName -DriverName $DriverName -DsnType $DsnType -SetPropertyValue @("User=$DbServerUserId", "Password=$DbServerPwd", "Description=$Description")
            Write-Host "DSN '$DsnName' created successfully."
        }
        catch {
            Write-Error "Failed to create DSN '$DsnName': $_"
        }
    }
    else {
        Write-Host "DSN '$DsnName' already exists. Skipping creation."
    }
}

function Add-MySQLLinkedServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$serverName,

        [Parameter(Mandatory)]
        [string]$linkedServerName,

        [Parameter(Mandatory)]
        [string]$dsnName,

        [Parameter(Mandatory)]
        [string]$mysqlUserName,

        [Parameter(Mandatory)]
        [string]$mySqlPwd,

        [switch]$Force
    )

    # Set connection string
    $connString = "Server=$serverName;Database=master;Integrated Security=True;"

    # Declare a variable to indicate existence of linked server
    [boolean]$linkedServerExists = $false

    # Check linked server existence
    try {
        $sql = "SELECT 1 FROM master.sys.servers WHERE name = N'$linkedServerName'"
        $linkedServerCheck = Invoke-SqlCmd  -ConnectionString $connString `
                                            -Query $sql

        $linkedServerExists = ($null -eq $linkedServerCheck) ? $false : $true
    }
    catch {
        Write-Error "Error checking linked server: $_"
    }

    # If linked server exists, and $Force, drop it.
    if ($linkedServerExists -and $Force) {
        try {
            $sql = "EXEC master.dbo.sp_dropserver N'$linkedServerName', 'droplogins'"
            Invoke-SqlCmd -ConnectionString $connString -Query $sql
            # The linked server no longer exists; update existence flag
            $linkedServerExists = $false
        }
        catch {
            Write-Error "Failed to drop linked server '$linkedServerName': $_"
            exit 1
        }
    }

    if (-not $linkedServerExists) {
        # T-SQL to create linked server based on ODBC DSN
        try {
            $sql = @"
            EXEC master.dbo.sp_addlinkedserver
                @server = N'$linkedServerName',
                @srvproduct = N'',
                @provider = N'MSDASQL',
                @datasrc = N'$dsnName'

	        -- Configure security (optional)
	        -- For Windows authentication:
            EXEC master.dbo.sp_addlinkedsrvlogin
                @rmtsrvname = N'$linkedServerName',
                @useself = N'False',
                @locallogin = NULL,
                @rmtuser = $mysqlUserName,
                @rmtpassword = $mySqlPwd
"@
            Invoke-SqlCmd -ConnectionString $connString -Query $sql
        }
        catch {
            Write-Error "Failed to create linked server '$linkedServerName': $_"
        }
    }
    else {
        Write-Error "Linked server '$linkedServerName' already exists."
    }
}

# Usage:

$mysqlUserName = 'root'
$mysqlPwd = 'root'

Start-Download  -DownloadUrl 'https://cdn.mysql.com/Downloads/Connector-ODBC/9.2/mysql-connector-odbc-9.2.0-winx64.msi' `
                -DownloadMessage 'Downloading driver' `
    | Install-MySqlOdbc  `
    | Add-MySqlOdbcDsn  -DsnName "DsnDemoUsingPSWebClient" `
                        -Description "DSN Created via Powershell" `
                        -DriverName "MySQL ODBC 9.2 ANSI Driver" `
                        -DsnType "System" `
                        -DbServerUserId $mysqlUserName `
                        -DbServerPwd $mysqlPwd `
                        -Force `
    | Add-MySQLLinkedServer -serverName 'DESKTOP-MJ0SQAI\MSSQLSERVER2019' `
                            -linkedServerName 'LinkedServerPS' `
                            -dsnName 'DsnDemoUsingPSWebClient' `
                            -mysqlUserName $mysqlUserName `
                            -mySqlPwd $mysqlPwd `
                            -Force

<#

The same can be achieved using the built-in `Invoke-WebRequest`

$mysqlUserName = 'root'
$mysqlPwd = 'root'

$downloadUrl = 'https://cdn.mysql.com/Downloads/Connector-ODBC/9.2/mysql-connector-odbc-9.2.0-winx64.msi'
$fileName = $downloadUrl | Split-Path -Leaf
$outFile = "$env:temp\$fileName"

Invoke-WebRequest   $downloadUrl -OutFile $outFile
Install-MySqlOdbc   $outFile -ErrorAction Stop
Add-MySqlOdbcDsn    -DsnName "DsnDemoUsingInvokeWebRequest" `
                    -Description "DSN Created via Powershell" `
                    -DriverName "MySQL ODBC 9.2 ANSI Driver" `
                    -DsnType "System" `
                    -DbServerUserId $mysqlUserName `
                    -DbServerPwd $mysqlPwd `
                    -Force
Add-MySQLLinkedServer -serverName 'DESKTOP-MJ0SQAI\MSSQLSERVER2019' `
                            -linkedServerName 'LinkedServerPS' `
                            -dsnName 'DsnDemoUsingPSWebClient' `
                            -mysqlUserName $mysqlUserName `
                            -mySqlPwd $mysqlPwd `
                            -Force

#>
