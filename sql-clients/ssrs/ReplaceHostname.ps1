<#
Currently this script needs to be run from the same directory reports and datasets exist in, top level
#>

$configFiles = Get-ChildItem . *.rdl -rec
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "http://ntbs-serv-rep/ReportServer", "http://SQLNISNTBSCOL03/ReportServer" `
						-replace "AzureSharedDev", "Staging" `
						-replace "AzureShared", "Staging" `
						-replace "<rd:DataSourceID>.*</rd:DataSourceID>", "" `
						-replace "<cl:ComponentId>.*</cl:ComponentId>", "" `
						-replace "<rd:ReportID>.*</rd:ReportID>", ""} |
    Set-Content $file.PSPath
}

$configFiles = Get-ChildItem . *.rsd -rec
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "http://ntbs-serv-rep/ReportServer", "http://SQLNISNTBSCOL03/ReportServer" `
						-replace "AzureSharedDev", "Staging"`
						-replace "AzureShared", "Staging" `
						-replace "<rd:DataSourceID>.*</rd:DataSourceID>", "" `
						-replace "<cl:ComponentId>.*</cl:ComponentId>", "" `
						-replace "<rd:ReportID>.*</rd:ReportID>", ""} |
    Set-Content $file.PSPath
}
