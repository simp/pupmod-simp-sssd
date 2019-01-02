require 'spec_helper'

describe 'sssd::ldap_access_order_defaults' do
  defaults = ['expire','lockout']

  context 'when sssd_version is not set' do
    it { is_expected.to run.and_return(defaults) }
  end

  sssd_versions = {
    '1.0.0' => defaults,
    '1.14.0' => defaults + ['ppolicy','pwd_expire_policy_reject','pwd_expire_policy_warn','pwd_expire_policy_renew'],
    '1.14.1' => defaults + ['ppolicy','pwd_expire_policy_reject','pwd_expire_policy_warn','pwd_expire_policy_renew'],
    '1.15.0' => defaults + ['ppolicy','pwd_expire_policy_reject','pwd_expire_policy_warn','pwd_expire_policy_renew']
  }

  sssd_versions.each do |sssd_version, expected_result|
    context "when sssd_version is #{sssd_version}" do
      let(:facts) {{
        :sssd_version => sssd_version
      }}

      it { is_expected.to run.and_return(expected_result) }
    end
  end
end
