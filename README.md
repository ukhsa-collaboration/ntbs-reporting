## How to install this codebase and the Integrated Development Environment (IDE) on your local computer ?

1. Download and install Visual Studio 2017 (Community) from https://visualstudio.microsoft.com/downloads/
	- During installation, select “Data storage and processing”

2. Download and install GIT from https://git-scm.com/downloads

3. Get your email address added to the GIT repository, which at the time of writing is at https://bitbucket.org/ben_leedham/phe-ntbs-summaries 

4. Navigate to your project folder on your local computer
	- Right click it, and "Git Bash here"
	- Type in: git clone https://{YOUR_BITBUCKET_USERNAME}@bitbucket.org/ben_leedham/phe-ntbs-summaries.git
	- Type in your bitbucket credentials when being prompted (alternatively, set yourself up an SSH key with bitbucket)

5. Prepare the "Base Databases" with the data to report on and the "Reporting Database" that end-users connect to
	- Create yourself an empty SQL Server instance
	- TODO: Extract "/{GIT_PROJECT_ROOT}/sql-server/build/1-base-databases/all-base-databases.zip"

5. Create the DacPacs (Data Access Component Packs)
	- After the GIT repository has download the your local computer, open a command prompt, and navigate into the "phe-ntbs-summaries" folder inside your project folder
	- From inside the "phe-ntbs-summaries" folder replace the following placeholders (eg <SQL_INSTANCE> = phentbssql.ukwest.cloudapp.azure.com\MSSQLSERVERDEV,1444 and <SQL_ADMIN_USER> = ntbsadmin and <SQL_ADMIN_PASSWORD> = ???), and execute the following three commands:
		- "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\sqlpackage.exe" /Action:Extract /SourceDatabaseName:"ETS" /SourceServerName:<SQL_INSTANCE> /SourceUser:<SQL_ADMIN_USER> /SourcePassword:<SQL_ADMIN_PASSWORD> /TargetFile:"data\DACPAC\ETS.dacpac"
		- "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\sqlpackage.exe" /Action:Extract /SourceDatabaseName:"Labbase2" /SourceServerName:<SQL_INSTANCE> /SourceUser:<SQL_ADMIN_USER> /SourcePassword:<SQL_ADMIN_PASSWORD> /TargetFile:"data\DACPAC\Labbase2.dacpac"
		- "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\sqlpackage.exe" /Action:Extract /SourceDatabaseName:"NTBS_R1_Geography_Staging" /SourceServerName:<SQL_INSTANCE> /SourceUser:<SQL_ADMIN_USER> /SourcePassword:<SQL_ADMIN_PASSWORD> /TargetFile:"data\DACPAC\NTBS_R1_Geography_Staging.dacpac"
	- This will have saved the dacpacs into your GIT repo
		- Verify that "/visual-studio/ntbs-reporting.sqlproj" contains relative references to these files, eg <ArtifactReference Include="..\data\DACPAC\ETS.dacpac">
		- This will result in these "References" to be recognised by "Visual Studio" in the "Solution Explorer" in the following

6. Open project in "Visual Studio"
	- Double-click "/visual-studio.sln" inside the "phe-ntbs-summaries" folder, and if prompted choose to open in "Visual Studio 2017"

7. Arrange panels
	- Click "View" in the main menu
	- Click "SQL Server Object Explorer" for this panel to appear
	- Check that the "Solution Explorer " and "Team Explorer" panels are already visible, but if not, add them

8. Connect to the SQL server(s)
	- In the "SQL Server Object Explorer" panel, right-click "SQL Server"
	- Choose "Add SQL Server"
	- Input SQL Server credentials with priviliges to create/modify/drop all DB objects amd even to grant/deny priviliges to other users

9. Right-click the "ntbs-reporting" node in "Solution Explorer"
	- Properties
	- Debug
	- Click the "Advanced" button at the bottom the window
	- Untick "Block incremental deployment if data loss might occur"

10. How to execute SQL in Visual Studio
	- Open up any SQL file you would like to execute
	- Press ALT/q + c + c, then ALT/q + c + c, then cick into "History", and select the DB connection
	- Press CTRL/SHIFT
	
## Coding standards

1. Indention
	- Use tabs for indentation (not spaces)
	- Tab size: 4
	- Indent size: 4
2. Object naming conventions
	- uspStoredProcName
	- udfFunctionName
	- vwViewName
	- TableName (no prefix)
	- Keys
		- Primary key: "TableNameId"
		- Foreign key column: "ReferenceTableNameId"
		- Foreign key name: "FK_ForeignKeyTableName_ForeignKeyColumnName"
	- Indexes
		- Primary index: "PK_TableName"
		- Other indexes: "IX_TableName_ColumnName"
3. File names
	- Any other repo-files (other than files naming the database objects from above) are to be named: lowercasename1-lowercasename2
4. Database references
	- Never hard-code any database names, but instead use SQLCMD variables, ie [$(DbVariable)].dbo.TableName
3. Report naming conventions
    - Report-specific end-user aggregate procs are named/prefixed after the name of their report, eg "uspCultureResistance"
    - Report-specific procs that pre-generate tables are namedprefixed with "uspGenerate" followed by the name of their report, eg "uspGenerateCultureResistance"
    - Report-specific pre-generated tables are prefixed with the name of their report, eg "CultureResistance"
