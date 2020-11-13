<#	  TODO
- add the 'Global.NIS.NTBS' to the start of the group name
- check that the group exists
- check that the user exists
#>

# BASED ON $version = "0.5"
clear-host
#region DBbit


	  
$requests = import-csv C:\Users\adil.mirza\Desktop\AD_Groups\AD_Group_Changes\NTBS_AD_Requests.csv



$DB = New-Object -TypeName psobject ; 
$DB | Add-Member -Name SQLServer -MemberType NoteProperty -value 'SQLITSMSCOL01\CLUELESS' ; 
$DB | Add-Member -name SQLDBName -MemberType NoteProperty -value 'GroupMemberships' ; 
$DB | Add-Member -name SqlConnection -MemberType NoteProperty -value $(New-Object System.Data.SqlClient.SqlConnection) ; 
$DB.SqlConnection.ConnectionString = "Server = $($DB.SQLServer); Database = $($DB.SQLDBName); Trusted_connection = True;" ; 
$DB | Add-Member -Name tEnrolled -MemberType NoteProperty -Value "[dbo].[EnrolledGroups]" ;
$DB | Add-Member -name Table -membertype noteproperty -value "[dbo].[GroupMembershipChangeLog]" ; 

#endregion DBbit

foreach ($request in $requests){
	#get next set of details
	$username = $($request.Username)
	$group = $($request."AD Group")
	$action = $($request.Action)
	
	$d = @{}
	$d.add("GroupIdentifier",$group)
	$d.add("Requestor","$($ENV:Username)")
	#$d
	
	#performing this check in each loop to avoid changing too much of the script
	if (((New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($env:username)))")).FindOne().GetDirectoryEntry().memberOf -match "Global.NIS.NTBS.GroupManagers") -or ((New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($env:username)))")).FindOne().GetDirectoryEntry().memberOf -match "Global.FAC.ICT.GroupMembership.UpdateRequestors")) `
		{
			switch ($($d.Requestor)) `
				{
					default
						{

							$DB.SqlConnection.open()

							$d.add("emailAddress",$username)
							$d.add("Action",$action)
							$validation = New-Object system.Data.DataTable
							$vselect = "select [GroupName], [SID] from [dbo].[EnrolledGroups] where [GroupName] = '$($d.GroupIdentifier)'"
							$SQL1 = $DB.SqlConnection.CreateCommand()
							$SQL1.commandtext = $vselect
							$r1 = $SQL1.executereader()
							$validation.load($r1)

							$DB.SqlConnection.close()

							Switch ($validation.Rows.Count) `
								{
									1 `
										{
											switch ($($d.emailAddress)) `
												{
													"" `
														{
															write-warning "Email address empty - fatal"
															exit
														}
													default `
														{
															switch ($($d.action))`
																{
																	"A" {continue}
																	"R" {continue}
																	default `
																		{
																			write-warning "Action must be either: 'A' or 'R'"
																			exit
																		}
																}
														}
												}
											continue
										}
									default `
										{
											Break
										}
								}

							$request = "Insert into $($DB.Table) ([emailAddress]
							,[Requestor]
							,[GroupIdentifier]
							,[Action]) VALUES ('$($d.emailAddress)'
							,'$($d.Requestor)'
							,'$($validation.rows[0].SID)'
							,'$(switch ($($d.Action)) `
								{
									A {1}
									R {0}
									default {break}
								})')"
							#Write-Host "$request"
							#Start-Sleep -Seconds 2
							$DB.SqlConnection.open()
							$SQL = $DB.SqlConnection.CreateCommand()
							$SQL.commandtext = $request
							switch ($SQL.executenonquery()) `
								{
									1 `
										{
											Clear-host
											Write-Host "Thank you - Request Received, and will be processed shortly.." -BackgroundColor green -ForegroundColor red
											Start-Sleep -Seconds 5
										}
									default {Write-Warning "Something Went Wrong!! :o"}
								}

							$DB.SqlConnection.Close()
						}
				}
		}
		

	else {Write-Warning "You do not have permission to make this request"}
	Start-Sleep -Seconds 1
}
	


