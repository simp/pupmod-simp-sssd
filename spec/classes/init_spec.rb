require 'spec_helper'

describe 'sssd' do
  let(:facts) {{
    :operatingsystem   => 'RedHat',
    :lsbmajdistrelease => '6',
    :fqdn              => 'example.test.domain',
    # for auditd/templates/base.erb:
    :hardwaremodel     => 'x86_64',
    :root_audit_level  => 'none',
    :grub_version      => '0',
    # for auditd/manifests/init.pp:
    :uid_min           => 500,
  }}

  it { should create_class('sssd') }
  it { should compile.with_all_deps }
  it { should contain_class('pki') }

  it { should contain_concat_build('sssd').with({
      :target => '/etc/sssd/sssd.conf',
      :notify => 'File[/etc/sssd/sssd.conf]'
    })
  }

  it { should contain_file('/etc/init.d/sssd').with({
      :ensure  => 'file',
      :source  => 'puppet:///modules/sssd/sssd.sysinit',
      :require => 'Package[sssd]',
      :notify  => 'Service[sssd]'
    })
  }

  it { should contain_file('/etc/sssd').with({
      :ensure  => 'directory',
    })
  }

  it { should contain_file('/etc/sssd/sssd.conf').with({
      :ensure  => 'file',
      :require => 'Package[sssd]',
      :notify  => 'Service[sssd]'
    })
  }

  it { should contain_package('sssd').with_ensure('latest') }
  it { should contain_service('nscd').with({
      :ensure => 'stopped',
      :enable => false,
      :notify => 'Service[sssd]'
    })
  }

  it { should contain_service('sssd').with({
      :ensure    => 'running',
      :require   => 'Package[sssd]',
      :subscribe => [
        'File[/etc/pki/cacerts]',
        'File[/etc/pki/public/example.test.domain.pub]',
        'File[/etc/pki/private/example.test.domain.pem]'
      ]
    })
  }
end
