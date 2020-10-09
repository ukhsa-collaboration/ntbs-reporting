CREATE PROCEDURE [dbo].[uspSampleMapping] AS


	SET NOCOUNT ON

	BEGIN TRY
		TRUNCATE TABLE SampleMapping

		INSERT INTO SampleMapping VALUES ('Aspirate', 1)
		INSERT INTO SampleMapping VALUES ('Biopsy', 2)
		INSERT INTO SampleMapping VALUES ('Blood', 3)
		INSERT INTO SampleMapping VALUES ('Bone', 4)
		INSERT INTO SampleMapping VALUES ('Bone and joint', 5)
		INSERT INTO SampleMapping VALUES ('Bone Biopsy', 6)
		INSERT INTO SampleMapping VALUES ('Bronchial lavage', 7)
		INSERT INTO SampleMapping VALUES ('Bronchial washings', 8)
		INSERT INTO SampleMapping VALUES ('Bronchoscopy', 9)
		INSERT INTO SampleMapping VALUES ('Bronchoscopy sample', 10)
		INSERT INTO SampleMapping VALUES ('CSF', 11)
		INSERT INTO SampleMapping VALUES ('Faeces', 12)
		INSERT INTO SampleMapping VALUES ('Gastric washings', 13)
		INSERT INTO SampleMapping VALUES ('Gynaecological', 14)
		INSERT INTO SampleMapping VALUES ('Hickman Line Tip', 15)
		INSERT INTO SampleMapping VALUES ('Lung bronchial tree tissue', 16)
		INSERT INTO SampleMapping VALUES ('Lymph node', 17)
		INSERT INTO SampleMapping VALUES ('Lymph tissue', 18)
		INSERT INTO SampleMapping VALUES ('LymphNode', 19)
		INSERT INTO SampleMapping VALUES ('Nasopharyngeal Aspirate', 20)
		INSERT INTO SampleMapping VALUES ('New', 98)
		INSERT INTO SampleMapping VALUES ('Non Directed Bronchial Lavage', 21)
		INSERT INTO SampleMapping VALUES ('Not known', 97)
		INSERT INTO SampleMapping VALUES ('Other tissues', 61)
		INSERT INTO SampleMapping VALUES ('Other tissues / sputum', 60)
		INSERT INTO SampleMapping VALUES ('Peritoneal fluid', 22)
		INSERT INTO SampleMapping VALUES ('Pleural', 23)
		INSERT INTO SampleMapping VALUES ('Pleural fluid or biopsy', 24)
		INSERT INTO SampleMapping VALUES ('PleuralFluidBiopsy', 25)
		INSERT INTO SampleMapping VALUES ('Pus', 26)
		INSERT INTO SampleMapping VALUES ('SKIN', 27)
		INSERT INTO SampleMapping VALUES ('SKIN/WOUND', 28)
		INSERT INTO SampleMapping VALUES ('Sputum', 29)
		INSERT INTO SampleMapping VALUES ('Sputum (induced)', 30)
		INSERT INTO SampleMapping VALUES ('UNKNOWN', 99)
		INSERT INTO SampleMapping VALUES ('Urine', 31)
	END TRY
	BEGIN CATCH
		THROW
	END CATCH