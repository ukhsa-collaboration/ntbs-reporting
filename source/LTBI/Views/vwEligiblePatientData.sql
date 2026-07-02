CREATE VIEW [LTBI].[vwEligiblePatientData]
	AS 
SELECT
      [Flag4FileName]                                                   AS SourceFileName
    , CASE WHEN HasPatientRecord = 1 THEN 'Yes' ELSE 'No' END           AS HasPatientRecord
    , [RecordNo]                                                        AS RecordNumber
    , [TestReason]                                                      AS TestReason
    , [SICBCode]                                                        AS SICBCode
    , [SICBName]                                                        AS SICBName
    , [CurrGPCode]                                                      AS CurrentGPCode
    , [CurrGPName]                                                      AS CurrentGPName
    , [CurrGPRegDate]                                                   AS CurrentGPRegistrationDate
    , [Flag4GPCode]                                                     AS Flag4GPCode
    , [Flag4GPName]                                                     AS Flag4GPName
    , [Flag4GPRegDate]                                                  AS Flag4GPRegistrationDate
    , [NHSNumber]                                                       AS NHSNumber
    , [GivenName]                                                       AS GivenName
    , [FamilyName]                                                      AS FamilyName
    , [Gender]                                                          AS Gender
    , [DOB]                                                             AS DateOfBirth
    , [COB]                                                             AS CountryOfBirth
    , [UKEntDate]                                                       AS UKEntryDate
    , [AddrLine1]                                                       AS AddressLine1
    , [AddrLine2]                                                       AS AddressLine2
    , [AddrLine3]                                                       AS AddressLine3
    , [AddrLine4]                                                       AS AddressLine4
    , [FullAddress]                                                     AS FullAddress
    , [AddrPcode]                                                       AS Postcode
    , [TelNo]                                                           AS TelephoneNumber
    , [MobTelNo]                                                        AS MobileNumber
    , [EmailAddr]                                                       AS EmailAddress
    , [ICBFromSICB]                                                     AS ICB_From_SICB
    , [ICBFromCurrGP]                                                   AS ICB_From_CurrentGP
    , [ICBFromFlag4GP]                                                  AS ICB_From_Flag4GP
    , [ICBFromPcode]                                                    AS ICB_From_Postcode
	FROM [LTBI].[EligiblePatientData];
