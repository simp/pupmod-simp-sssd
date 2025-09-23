require 'spec_helper_acceptance'
require 'beaker-windows'
require 'erb'

test_name 'Prepare Windows for AD'

describe 'AD' do
  ad_servers  = hosts_with_role(hosts, 'ad')
  domain_pass = '@dm1n=P@ssw0r'

  ad_servers.each do |server|
    domain = fact_on(server, 'domain').strip
    ldap_dc = domain.split('.').map { |x| "DC=#{x}" }.join(',')

    it 'installs the AD feature' do
      # https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-#BKMK_PS
      exec_ps_script_on(server, 'Install-WindowsFeature AD-Domain-Services -IncludeManagementTools')
      exec_ps_script_on(server, 'Import-Module ADDSDeployment')
      forest_cmd = [
        # https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-1/
        "$Pass = '#{domain_pass}' | ConvertTo-SecureString -AsPlainText -Force ;",
        'Install-ADDSForest',
        '-Force',
        %(-DomainName "#{domain}"),
        '-InstallDns',
        '-SafeModeAdministratorPassword $Pass',
        '-LogPath C:\Windows\Logs',
      ].join(' ')
      # this command reboots the system
      on(server, exec_ps_cmd(forest_cmd), expect_connection_failure: true)
    end

    it 'adds unix compatibility' do
      # on(server, exec_ps_cmd('dism.exe /online /enable-feature /featurename:adminui /featurename:nis /all /quiet'))
      on(server, exec_ps_cmd('Enable-WindowsOptionalFeature -Online -FeatureName NIS -All -NoRestart'))
      on(server, exec_ps_cmd('Enable-WindowsOptionalFeature -Online -FeatureName AdminUI -All -NoRestart'))
    end

    it 'sets the time' do
      time_cmd = 'w32tm.exe /config /manualpeerlist:"time.nist.gov" /syncfromflags:manual /reliable:YES /update'
      on(server, time_cmd)
      on(server, 'w32tm.exe /config /update')
      exec_ps_script_on(server, 'Restart-Service w32time')
      server.reboot
    end

    context 'should be a healthy AD server' do
      it 'has clean logs' do
        # Need to remove all old Event Viewer messages first
        on(server, exec_ps_cmd('wevtutil el | Foreach-Object {wevtutil cl "$_"}'))
      end
      it 'with a healthy forest' do
        # https://technet.microsoft.com/en-us/library/cc758753(v=ws.10).aspx
        result = on(server, 'dcdiag')
        expect(result.stdout).not_to match(%r{failed})
      end
      # it 'with a healthy DDNS service' do
      #   result = on(server, 'dcdiag /test:dns /DnsDynamicUpdate')
      #   expect(result.stdout).not_to match(/fail/)
      # end
    end

    it 'sets the Administrator password' do
      cmd = [
        '([adsi]\\"WinNT://' + domain.split('.').first.upcase + '/Administrator\\").SetPassword(\\"',
        domain_pass,
        '\\")',
      ].join
      on(server, exec_ps_cmd(cmd))
    end

    it 'creates test users' do
      users_csv = <<~EOF
        SamAccountName;GivenName;Surname;Name;Password
        mike.hammer;Mike;Hammer;Mike Hammer;suP3rP@ssw0r!
        john.franklin;John;Franklin;John Franklin;suP3rP@ssw0r!
        davegrohl;Dave;Grohl;Dave Grohl;suP3rP@ssw0r!
      EOF
      create_remote_file(server, 'C:\users.csv', users_csv)

      sleep 90
      @ldap_dc = ldap_dc
      @domain = domain
      exec_ps_script_on(server, ERB.new(File.read(File.join(File.dirname(__FILE__), 'files/populate_ad.ps1'))).result(binding))
      sleep 40
    end

    it 'has users from the CSV and vagrant' do
      # https://social.technet.microsoft.com/Forums/ie/en-US/67aab9d3-1ced-4d33-8252-66a6f88713b0/exporting-ad-user-list-to-a-text-or-excel-document?forum=winserverDS
      result = exec_ps_script_on(server, 'Get-ADUser -Filter * -SearchBase "' + ldap_dc + '" | select Name')
      expect(result.stdout).to match(%r{vagrant})
      expect(result.stdout).to match(%r{Mike Hammer})
      expect(result.stdout).to match(%r{John Franklin})
    end
  end
end
