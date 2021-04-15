## Developer guide: DELETE profiles

For typical deployment of new code, we have defensive settings in the publish profile to:
- block deployment where data loss will occur
- preserve objects in the target database schema which do not exist in the project schema.

For very small changes where this setting is too restrictive (e.g. a change to an existing column) you can truncate the relevant table and repopulate it using `uspGenerate` after deploying the new code.

For more extensive changes where many objects are being deleted or refactored, you will need less defensive settings in the publish profile.  Each environment has a separate publish profile to be used for deletions and these live in the 'DELETE' folder.  The profile does not delete all types of database object but is set to drop the type of objects we typically create during development:
* tables
* views
* stored procedures
* functions