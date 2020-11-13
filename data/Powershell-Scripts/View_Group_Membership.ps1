$version = "0.5"
clear-host
$directorysearcher = new-object system.directoryServices.DirectorySearcher "(&(objectClass=group)(name=Global.NIS.NTBS.*))"
$groups=$directorysearcher.FindAll()

      $results = foreach($group in $groups)
      {                       
                                             "-------------------------------"
                                             $group.Properties.cn
                                             "-------------------------------"
                                             
            $group.Properties.member
                                             "`n"
      }
                 $results = $results -replace "CN=","" -replace "OU=User Objects - Employee Accounts", "" -replace "OU=Administrated Objects", "" -replace "DC=phe", "" -replace "DC=gov", "" -replace "DC=uk", ""
                # $results
		 
		$results | Out-File  C:\Users\adil.mirza\Desktop\AD_Groups\Users_$((Get-Date).ToString('dd-MM-yyyy')).csv -Encoding utf8
