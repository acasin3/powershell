$ROOT_FOLDER = "C:\Users\User\root\"
$SCHEMAS_FOLDER = $ROOT_FOLDER + "Schemas\"
$TABLES_FOLDER = $ROOT_FOLDER + "Tables\"
$VIEWS_FOLDER = $ROOT_FOLDER + "Views\"
$STORED_PROCEDURES_FOLDER = $ROOT_FOLDER + "StoredProcedures\"
$USER_DEFINED_FUNCTIONS_FOLDER = $ROOT_FOLDER + "UserDefinedFunctions\"
$SYNONYMS_FOLDER = $ROOT_FOLDER + "Synonyms\"
$USERS_FOLDER = $ROOT_FOLDER + "Users\"

if (Test-Path $SCHEMAS_FOLDER) {Remove-Item $SCHEMAS_FOLDER -Force}
if (Test-Path $TABLES_FOLDER) {Remove-Item $TABLES_FOLDER -Force}
if (Test-Path $VIEWS_FOLDER) {Remove-Item $VIEWS_FOLDER -Force}
if (Test-Path $STORED_PROCEDURES_FOLDER) {Remove-Item $STORED_PROCEDURES_FOLDER -Force}
if (Test-Path $USER_DEFINED_FUNCTIONS_FOLDER) {Remove-Item $USER_DEFINED_FUNCTIONS_FOLDER -Force}
if (Test-Path $SYNONYMS_FOLDER) {Remove-Item $SYNONYMS_FOLDER -Force}
if (Test-Path $USERS_FOLDER) {Remove-Item $USERS_FOLDER -Force}

New-Item -ItemType Directory -Path $SCHEMAS_FOLDER
New-Item -ItemType Directory -Path $TABLES_FOLDER
New-Item -ItemType Directory -Path $VIEWS_FOLDER
New-Item -ItemType Directory -Path $STORED_PROCEDURES_FOLDER
New-Item -ItemType Directory -Path $USER_DEFINED_FUNCTIONS_FOLDER
New-Item -ItemType Directory -Path $SYNONYMS_FOLDER
New-Item -ItemType Directory -Path $USERS_FOLDER

Move-Item -Path *.Schema.sql -Destination $SCHEMAS_FOLDER
Move-Item -Path *.Table.sql -Destination $TABLES_FOLDER
Move-Item -Path *.View.sql -Destination $VIEWS_FOLDER
Move-Item -Path *.StoredProcedure.sql -Destination $STORED_PROCEDURES_FOLDER
Move-Item -Path *.UserDefinedFunction.sql -Destination $USER_DEFINED_FUNCTIONS_FOLDER
Move-Item -Path *.Synonym.sql -Destination $SYNONYMS_FOLDER
Move-Item -Path *.User.sql -Destination $USERS_FOLDER

# Rename Schema Files
Get-ChildItem $SCHEMAS_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".Schema", "")
} 

# Rename Table Files
Get-ChildItem $TABLES_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".Table", "")
}

# Rename View Files
Get-ChildItem $VIEWS_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".View", "")
}

# Rename Stored Procedure Files
Get-ChildItem $STORED_PROCEDURES_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".StoredProcedure", "")
}

# Rename UDF Files
Get-ChildItem $USER_DEFINED_FUNCTIONS_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".UserDefinedFunction", "")
}

# Rename Synonym Files
Get-ChildItem $SYNONYMS_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".Synonym", "")
}

# Rename User Files
Get-ChildItem $USERS_FOLDER |
ForEach-Object {
    Rename-Item -Path $_.FullName -NewName $_.FullName.Replace(".User", "")
}
