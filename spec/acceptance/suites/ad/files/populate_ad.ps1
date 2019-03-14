# Taken from https://github.com/StefanScherer/adfs2/blob/master/scripts/fill-ad.ps1

Import-Module ActiveDirectory
NEW-ADOrganizationalUnit -name "IT-Services"
NEW-ADOrganizationalUnit -name "SupportGroups" -path "OU=IT-Services,<%= @ldap_dc %>"
NEW-ADOrganizationalUnit -name "CostCenter" -path "OU=SupportGroups,OU=IT-Services,<%= @ldap_dc %>"


NEW-ADOrganizationalUnit -name "Locations"
NEW-ADOrganizationalUnit -name "HeadQuarter" -path "OU=Locations,<%= @ldap_dc %>"
NEW-ADOrganizationalUnit -name "Users" -path "OU=HeadQuarter,OU=Locations,<%= @ldap_dc %>"

Import-CSV -delimiter ";" C:\users.csv | foreach {
  New-ADUser -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.Surname -Name $_.Name `
             -Path "OU=Users,OU=HeadQuarter,OU=Locations,<%= @ldap_dc %>" `
             -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -Enabled $true
}

New-ADGroup -Name "SecurePrinting" -SamAccountName SecurePrinting -GroupCategory Security -GroupScope Global -DisplayName "Secure Printing Users" -Path "OU=SupportGroups,OU=IT-Services,<%= @ldap_dc %>"
New-ADGroup -Name "CostCenter-123" -SamAccountName CostCenter-123 -GroupCategory Security -GroupScope Global -DisplayName "CostCenter 123 Users" -Path "OU=CostCenter,OU=SupportGroups,OU=IT-Services,<%= @ldap_dc %>"
New-ADGroup -Name "CostCenter-125" -SamAccountName CostCenter-125 -GroupCategory Security -GroupScope Global -DisplayName "CostCenter 125 Users" -Path "OU=CostCenter,OU=SupportGroups,OU=IT-Services,<%= @ldap_dc %>"

Add-ADGroupMember -Identity SecurePrinting -Member CostCenter-125

Add-ADGroupMember -Identity CostCenter-125 -Member mike.hammer
Add-ADGroupMember -Identity CostCenter-123 -Member john.franklin

Get-AdUser -Filter * -SearchBase "OU=Users,OU=HeadQuarter,OU=Locations,<%= @ldap_dc %>" -Properties msSFU30NisDomain | Set-ADUser -Replace @{msSFU30NisDomain = '<%= @domain.split('.').first %>'}
Get-AdUser -Filter * -SearchBase "OU=Users,OU=HeadQuarter,OU=Locations,<%= @ldap_dc %>" -Properties gidnumber | Set-ADUser -Replace @{gidnumber = 40000}


Get-AdUser -Filter {samaccountname -like "davegrohl"} | Set-ADUser -Replace @{uidnumber = 60000}
Get-AdUser -Filter {samaccountname -like "mike.hammer"} | Set-ADUser -Replace @{uidnumber = 60001}
Get-AdUser -Filter {samaccountname -like "john.franklin"} | Set-ADUser -Replace @{uidnumber = 60002}
