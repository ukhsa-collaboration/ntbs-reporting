## Developer guide

This database project is dependent upon multiple other databases to work correctly. At the time of writing, there is no easy way to restore a local copy of each of these dependencies. Moreover, the project requires the databases to all run on the same instance of SQL Server, meaning that we do not currently have a way to set up a local development environment for this project.

In most cases, development should be done against the `int` environment on the `ntbs-ops-dbs` server. Since it may be difficult to resolve conflicts with multiple developers working against the same database, the currently recommended branching strategy is to commit changes directly onto the `master` branch.

Make sure that you have the following tools installed locally:

- Visual Studio 2017 (or later) - this can be downloaded from https://visualstudio.microsoft.com/downloads/
	- During installation, select “Data storage and processing”

- Git - this can be downloaded from https://git-scm.com/downloads

You can then begin working on the project by cloning the repository and opening `VisualStudio_ntbs-reporting.sln` in Visual Studio.

To make a change to the project you should then:

1. Create or update the relevant table, function, stored procedure, etc. in the appropriate directory.

1. In the `Solution Explorer` window, double click on the `azure-ntbs-int-reporting.publish.xml` file.

1. In the pop-up window, next to the `Target database connection` select `Edit...`, and enter the password for the `sqlAdmin` user - this can be found in the `ntbs-ops-dbs-credentials` secret in Azure. (If you also check `Remember password` then you do not need to repeat this step in future).

1. Click `Generate Script`. Review the SQL script that is generated, and confirm that it is reflective of your changes.

1. Double click on the `azure-ntbs-int-reporting.publish.xml` file again, and this time select `Publish`. This will push your change to the `int` database.

1. Commit the change in git and push straight to the `master` branch.

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
