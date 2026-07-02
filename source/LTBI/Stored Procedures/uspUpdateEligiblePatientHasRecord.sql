CREATE PROCEDURE [dbo].[uspUpdateEligiblePatientHasRecord]
	
AS

Update e 
Set HasPatientRecord = 1
From LTBI.EligiblePatientData e
Inner join [$(NTBS)].LTBI.LTBIPatient p on p.PatNHS = e.NHSNumber
where e.HasPatientRecord = 0;