## Developer guide

## Getting started

This database project is dependent upon multiple other databases to work correctly. Follow these instructions to set up a version of the database on your local machine for development purposes.

Pre-requisites:

- Install a SQL Server instance (any version from 2016 onwards should be fine) - set the default collation to Latin1_General_CI_AS
- Install SQL Server Management Studio (SSMS).
- Install Visual Studio 2017 (or later) - this can be downloaded from https://visualstudio.microsoft.com/downloads/
    - During installation, select "Data storage and processing"
- Install Git - this can be downloaded from https://git-scm.com/downloads

Steps:

1. Follow the instructions for setting up the NTBS application in the [ntbs_Beta repository](https://github.com/publichealthengland/ntbs_Beta/blob/master/ntbs-service/README.md).

1. Follow the instructions for setting up the NTBS migration database in the [ntbs-data-migration repository](https://github.com/publichealthengland/ntbs-data-migration/blob/master/README.md).
    - Make sure that you have run the NTBS app, so that the application and audit databases are migrated
1. Restore a backup of the geography database by carrying out the following steps:
    1. Download a copy of the test-geography database from https://phecloud.sharepoint.com/:f:/r/sites/NTBSResources/Project/Developer%20Guide/Database%20backups?csf=1&web=1&e=WAYaKI
    1. In SSMS, connect to your SQL Server instance.
    1. In the `Object Explorer` panel, right-click on `Databases` and select `Restore Database...`.
    1. Select the `Device` radio button, and add the relevant back up file via the `...` button.
    1. Change the name of the database from `int-geography` to `geography`.
    1. Click `OK`.
    1. You should see a message saying that the database has restored successfully.
1. Set up specimen matching database:
    1. Clone the [specimen-matching repository](https://github.com/publichealthengland/ntbs-specimen-matching).
    1. Make a copy of the `DEV-specimen-matching.publish.xml` file, named `DEV-USER-specimen-matching.publish.xml`. This file will be ignored by git.
    1. If the instance of SQL Server that you are using is not at `localhost` then update the `Data Source` in the `TargetConnectionString`.
    1. Double click on this config in the `Solution Explorer` panel in Visual Studio to publish the codebase. This will build the relevant views and set up the relevant tables.
1. Clone this repository and open `VisualStudio_ntbs-reporting.sln` in Visual Studio.
1. Create personal publish profiles for databases on your branch:
    1. Make a copy of `DEV-reporting.publish.xml` and name it `DEV-USER-reporting.publish.xml`. This file will be ignored by Git.
    1. Make a copy of `DEV-reporting-DELETE.publish.xml` and name it `DEV-USER-reporting-DELETE.publish.xml`. This file will be ignored by Git.
1. If the instance of SQL Server that you are using is not at `localhost` then update the `Data Source` in the `TargetConnectionString`.
1. Double-click on this config in the `Solution Explorer` panel in Visual Studio to publish the codebase. This will build the relevant views and set up the relevant tables.
1. To populate the database, do the following:
    1. Run the stored procedure `uspGenerate` in the specimen matching database.
        - At this point the NTBS application should run, but some Hangfire jobs and legacy notification importing will not work properly with unpopulated specimen matching and reporting databases.
        - If this stored procedure fails, try creating at least three notifications in the NTBS application. The specimen matching process is quite fragile when there is small amounts of data, previous issues have been caused by: all patients having the same gender, or exactly one patient having a house number at the start of their address.
    1. Run the stored procedure `uspGenerate` in the reporting database.
        - If this fails with an "expressions services limit" error, set the database to a compatibility level of 140 (SQL Server 2017) by right clicking the database and going to "Properties" and then "Options".

To make a change to the project you should then:

1. Create or update the relevant table, function, stored procedure, etc. in the appropriate directory.
2. Go through step 3 of making a new copy to publish the changes to your database.
3. Run `uspGenerate` on the newly published changes.

To release changes:

1. Push your changes to a feature branch, and open a pull request.
2. Once this has been merged into `master`, the changes can be published to other databases for QA and active use using the relevant `publish.xml` scripts for each database.
    1. If your code needs to delete unused objects in the database, use the equivalent DELETE profile - see the DELETE folder for more details.

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
