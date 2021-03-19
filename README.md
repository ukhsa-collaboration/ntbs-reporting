## Developer guide

This database project is dependent upon multiple other databases to work correctly. At the time of writing, there is no easy way to restore a local copy of each of these dependencies. Moreover, the project requires the databases to all run on the same instance of SQL Server, meaning that we do not currently have a way to set up a local development environment for this project.
However, it is possible to set up a new reporting database in this environment, to do your development against in a feature branch. In most cases, the dependencies of the reporting databases should be the `int` versions of the relevant databases (`int-geography`, `int-ntbs`, etc.)

Make sure that you have the following tools installed locally:

- Visual Studio 2017 (or later) - this can be downloaded from https://visualstudio.microsoft.com/downloads/
	- During installation, select "Data storage and processing"

- Git - this can be downloaded from https://git-scm.com/downloads

You can then begin working on the project by cloning the repository and opening `VisualStudio_ntbs-reporting.sln` in Visual Studio.

To make a new copy of the reporting database, do the following:
1. Make a copy of `azure-ntbs-int-reporting.publish.xml` and name it `azure-ntbs-USER-reporting.publish.xml`. This file will be ignored by Git.
2. Edit this file, replacing the `TargetDatabaseName` value with the name of the new reporting database you would like to create. This database should not exist on the Azure SQL Server yet.
3. Publish this database, by double clicking on the xml file in the VS Solution explorer:
    1. In the pop-up window, next to the `Target database connection` select `Edit...`, and enter the password for the `sqlAdmin` user - this can be found in the `ntbs-ops-dbs-credentials` secret in Azure. (If you also check `Remember password` then you do not need to repeat this step in future).
    2. Click `Generate Script`. Review the SQL script that is generated, and confirm that it is reflective of your changes. In this case, it should be creating all of the tables, and adding all of the functions and stored procedures.
    3. When you are happy with this script, double click on the xml file again and then click `Publish` in the dialog box that pops up. This will generate the same script again, and then run it on the SQL server, creating your new database in the process.
4. To populate the database:
    1. Run the stored procedure `uspPopulateCalendarTable`
    2. Run the a SQL command based on the script in `source/Scripts/PopulateFeatureFlags.sql`. To make a dev database, you will want to set the three numbers being inserted to `1, 1, 1` instead of the default `0, 0, 0`.
    3. Run the stored procedure `uspGenerate`

To make a change to the project you should then:

1. Create or update the relevant table, function, stored procedure, etc. in the appropriate directory.
2. Go through step 3 of making a new copy to publish the changes to your database.
3. Run `uspGenerate` on the newly published changes.

To release changes:

1. Push your changes to a feature branch, and open a pull request.
2. Once this has been merged into `master`, the changes can be published to other databases for QA and active use using the relevant `publish.xml` scripts for each database.

## Coding standards

1. Indention
	- Use tabs for indentation (not spaces)
	- Tab size: 4
	- Indent size: 4
2. Object naming conventions
	- uspStoredProcName
	- ufnFunctionName
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
