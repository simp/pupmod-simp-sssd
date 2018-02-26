require 'spec_helper_acceptance'
require 'beaker-windows'
require 'erb'

test_name 'Prepare Windows for AD'

describe 'AD' do

  ad_servers  = hosts_with_role(hosts,'ad')
  domain_pass = '@dm1n=P@ssw0r'

  ad_servers.each do |server|
    it 'should install the AD feature' do
      # https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-#BKMK_PS
      exec_ps_script_on(server, 'Install-WindowsFeature AD-Domain-Services -IncludeManagementTools')
      exec_ps_script_on(server, 'Import-Module ADDSDeployment')
      forest_cmd = [
        # https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-1/
        "$Pass = '#{domain_pass}' | ConvertTo-SecureString -AsPlainText -Force ;",
        'Install-ADDSForest',
        '-Force',
        '-DomainName "test.case"',
        '-InstallDns',
        '-SafeModeAdministratorPassword $Pass',
        '-LogPath C:\Windows\Logs'
      ].join(' ')
      # this command reboots the system
      on(server, exec_ps_cmd(forest_cmd), expect_connection_failure: true)
    end

    it 'should set the time' do
      time_cmd = 'w32tm.exe /config /manualpeerlist:"time.nist.gov" /syncfromflags:manual /reliable:YES /update'
      on(server, time_cmd)
      on(server, 'w32tm.exe /config /update')
      exec_ps_script_on(server, 'Restart-Service w32time')
      server.reboot
    end

    it 'should be a healthy AD server' do
      # Need to remove all old Event Viewer messages first
      on(server, exec_ps_cmd('wevtutil el | Foreach-Object {wevtutil cl "$_"}'))

      # https://technet.microsoft.com/en-us/library/cc758753(v=ws.10).aspx
      result = on(server, 'dcdiag')
      expect(result.stdout).not_to match(/failed/)
    end

    it 'should create a test user' do
      users_csv = <<-EOF.gsub(/^\s{8}/,'')
        SamAccountName;GivenName;Surname;Name;Password
        mike.hammer;Mike;Hammer;Mike Hammer;Pa$sw0rd
        john.franklin;John;Franklin;John Franklin;Pa$sw0rd
        davegrohl;Dave;Grohl;Dave Grohl;Pa$sw0rd
      EOF
      create_remote_file(server, 'C:\users.csv', users_csv)

      sleep 90
      exec_ps_script_on(server, File.read('spec/acceptance/suites/ad/files/populate_ad.ps1'))
      sleep 40

    end

    it 'should have users TestUser and vagrant' do
      # https://social.technet.microsoft.com/Forums/ie/en-US/67aab9d3-1ced-4d33-8252-66a6f88713b0/exporting-ad-user-list-to-a-text-or-excel-document?forum=winserverDS
      result = exec_ps_script_on(server, 'Get-ADUser -Filter * -SearchBase "DC=test,DC=case" | select Name')
      expect(result.stdout).to match(/vagrant/)
      expect(result.stdout).to match(/Mike Hammer/)
      expect(result.stdout).to match(/John Franklin/)
    end
  end
end
