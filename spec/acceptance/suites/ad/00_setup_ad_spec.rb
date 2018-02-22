require 'spec_helper_acceptance'
require 'beaker-windows'

test_name 'Prepare Windows for AD'

describe 'AD' do

  ad_servers  = hosts_with_role(hosts,'ad')
  domain_pass = '@dm1n=P@ssw0r'

  ad_servers.each do |server|
    it 'should install the AD feature' do
      # https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-#BKMK_PS
      on(server, exec_ps_cmd('Install-WindowsFeature AD-Domain-Services -IncludeManagementTools'))
      on(server, exec_ps_cmd('Import-Module ADDSDeployment'))
      forest_cmd = [
        # https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-1/
        "$Pass = '#{domain_pass}' | ConvertTo-SecureString -AsPlainText -Force ;",
        'Install-ADDSForest',
        '-Force',
        '-DomainName "test.case"',
        '-InstallDns',
        '-SafeModeAdministratorPassword $Pass',
        '-LogPath C:\Windows\Logs'
        # '-CreateDnsDelegation',
        # '-DomainMode "Win2012R2"',
        # '-ForestMode "Win2012R2"',
      ].join(' ')
      # this command reboots the system
      on(server, exec_ps_cmd(forest_cmd), expect_connection_failure: true)
    end

    it 'should set the time' do
      time_cmd = 'w32tm.exe /config /manualpeerlist:"time.nist.gov" /syncfromflags:manual /reliable:YES /update'
      on(server, exec_ps_cmd(time_cmd))
      on(server, exec_ps_cmd('w32tm.exe /config /update'))
      on(server, exec_ps_cmd('Restart-Service w32time'))
      server.reboot
    end

    it 'should be a healthy AD server' do
      # https://technet.microsoft.com/en-us/library/cc758753(v=ws.10).aspx
      result = on(server, exec_ps_cmd('dcdiag'))
      require 'pry'; binding.pry
      expect(result.stdout).not_to match(/failed/)
    end

    it 'should create a test user' do
      # https://redmondmag.com/articles/2016/08/09/create-an-active-directory-account-in-powershell.aspx
      add_user_cmd = [
        "$Pass = '#{domain_pass}' | ConvertTo-SecureString -AsPlainText -Force ;",
        'New-ADUser -Name TestUser',
        '-AccountPassword $Pass',
        '-PassThru | Enable-ADAccount'
      ].join(' ')
      on(server, exec_ps_cmd(add_user_cmd))
    end

    it 'should have users TestUser and vagrant' do
      # https://social.technet.microsoft.com/Forums/ie/en-US/67aab9d3-1ced-4d33-8252-66a6f88713b0/exporting-ad-user-list-to-a-text-or-excel-document?forum=winserverDS
      result = on(server, exec_ps_cmd('dsquery user -name * -limit 0'))
      require 'pry'; binding.pry
      expect(result.stdout).to match(/CN=vagrant/)
      expect(result.stdout).to match(/CN=TestUser/)
    end
  end
end
