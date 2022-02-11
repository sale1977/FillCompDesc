# Users write information about the computer hardware/model in the Description field in Active Directory
# Link to User Organizational Unit => PowerShell Script at Startup. 
# Delegate Permission: dsacls "OU=Clients,OU=Computer,OU=Campus,DC=test,DC=lab" /I:S /G "NT-AUTORITÄT\Authentifizierte Benutzer:WP;description;user"
# http://woshub.com/how-automatically-fill-computer-description-field-in-active-directory/
# https://lockstepgroup.com/blog/fun-with-ad-custom-attributes/
$computer = $env:COMPUTERNAME
$computerinfo= Get-WMIObject Win32_ComputerSystemProduct
$Vendor = $computerinfo.vendor
$Model = $computerinfo.Name
$SerialNumber = $computerinfo.identifyingNumber
$DNSDOMAIN= (Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Domain
$ComputerSearcher = New-Object DirectoryServices.DirectorySearcher
$ComputerSearcher.SearchRoot = "LDAP://$("DC=$(($DNSDOMAIN).Replace(".",",DC="))")"
$ComputerSearcher.Filter = "(&(objectCategory=Computer)(CN=$Computer))"
$computerObj = [ADSI]$ComputerSearcher.FindOne().Path
# $computerObj.Put("Description", "$vendor|$Model|$SerialNumber" )
$computerObj.Put("Description","$vendor|$Model|$SerialNumber|$env:username|$env:LOGONSERVER")
$computerObj.SetInfo()