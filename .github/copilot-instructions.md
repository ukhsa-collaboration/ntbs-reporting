# Copilot Instructions

## Project Guidelines
- For LTBI eligible patient ingestion, prefer using clean data already loaded in NTBS LTBI schema tables rather than reproducing transformations from the old staging-table workflow.
- For LTBI eligible valid-record ingestion from LTBI.Address, map AddrTownCity to reporting AddressLine3 and AddrCnty to reporting AddressLine4.