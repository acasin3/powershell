# Powershell

Collection of useful powershell scripts

## SQLServerDBObjects

Moves scripts generated by SQL Server Management Studio to pre-defined folders by type, i.e., :
- files ending in Schema.sql will be moved to the Schemas folder
- files ending in Table.sql will be moved to the Tables folder
- files ending in View.sql will be moved to the Views folder
- files ending in StoredProcedure.sql will be moved to the StoredProcedures folder
- files ending in UserDefinedFunction.sql will be moved to the UserDefinedFunctions folder
- files ending in Synonym.sql will be moved to the Synonyms folder
- files ending in User.sql will be moved to the Users folder

To generate the scripts in SQL Server Management Studio, please see
https://support.sqldbm.com/knowledge-bases/2/articles/245-how-to-generate-sql-script-from-sql-management-studio-for-reverse-engineering
