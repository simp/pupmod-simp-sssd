require 'spec_helper'

describe 'sssd::sudo_on' do
  it { is_expected.to run.with_params({}).and_return(true) }
  it { is_expected.to run.with_params({ 'sudo' => {} }).and_return(true) }
  it { is_expected.to run.with_params({ 'sudo' => { 'ensure' => 'absent' } }).and_return(false) }
  it { is_expected.to run.with_params({ 'sudo' => {} }, ['nss']).and_return(false) }
  it { is_expected.to run.with_params({}, ['nss', 'sudo']).and_return(true) }
  it { is_expected.to run.with_params({}, []).and_return(false) }
end
