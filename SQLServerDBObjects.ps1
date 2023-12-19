$ROOT_FOLDER = "C:\Users\User\root\"
$SCHEMAS_FOLDER = $ROOT_FOLDER + "Schemas"
$TABLES_FOLDER = $ROOT_FOLDER + "Tables"
$VIEWS_FOLDER = $ROOT_FOLDER + "Views"
$STORED_PROCEDURES_FOLDER = $ROOT_FOLDER + "StoredProcedures"
$USER_DEFINED_FUNCTIONS_FOLDER = $ROOT_FOLDER + "UserDefinedFunctions"
$SYNONYMS_FOLDER = $ROOT_FOLDER + "Synonyms"
$USERS_FOLDER = $ROOT_FOLDER + "Users"

Move-Item -Path *.Schema.sql -Destination $SCHEMAS_FOLDER
Move-Item -Path *.Table.sql -Destination $TABLES_FOLDER
Move-Item -Path *.View.sql -Destination $VIEWS_FOLDER
Move-Item -Path *.StoredProcedure.sql -Destination $STORED_PROCEDURES_FOLDER
Move-Item -Path *.UserDefinedFunctions.sql -Destination $USER_DEFINED_FUNCTIONS_FOLDER
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