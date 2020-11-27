 Create View vwForestBuild AS
 select replace((select right([ForestFilename], charindex(' ', reverse([ForestFilename]) + ' ') - 1) from [ForestFilename]),'.csv','') as BuildNumber