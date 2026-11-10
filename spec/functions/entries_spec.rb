require 'spec_helper'

describe 'sssd::entries' do
  it { is_expected.to run.with_params({}).and_return({}) }

  it 'defaults each entry to present' do
    is_expected.to run.with_params({ 'nss' => {}, 'pam' => { 'ensure' => 'present' }, 'ssh' => { 'ensure' => 'absent' } })
                      .and_return({ 'nss' => 'present', 'pam' => 'present', 'ssh' => 'absent' })
  end

  it 'uses the deprecated Array instead of the Hash when it is set' do
    is_expected.to run.with_params({ 'nss' => {} }, ['pam', '--ssh'])
                      .and_return({ 'pam' => 'present', 'ssh' => 'absent' })
  end

  it 'uses an empty deprecated Array instead of the Hash' do
    is_expected.to run.with_params({ 'nss' => {} }, []).and_return({})
  end

  it 'uses the Hash when the deprecated Array is undef' do
    is_expected.to run.with_params({ 'nss' => {} }, nil).and_return({ 'nss' => 'present' })
  end

  it 'rejects an unknown option' do
    is_expected.to run.with_params({ 'nss' => { 'ensrue' => 'absent' } }).and_raise_error(%r{unrecognized key 'ensrue'})
  end

  it 'rejects an unknown ensure value' do
    is_expected.to run.with_params({ 'nss' => { 'ensure' => 'absnet' } }).and_raise_error(%r{expects a match for Enum})
  end
end
