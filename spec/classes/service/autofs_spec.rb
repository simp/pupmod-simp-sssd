require 'spec_helper'

describe 'sssd::service::autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.to create_sssd__config__entry('puppet_service_autofs').without_content(%r{=\s*$}) }
        end

        context 'with custom options' do
          let(:params) do
            {
              'custom_options' =>  { 'key1' => 'value1', 'key2' => 'value2' },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it {
            is_expected.to create_sssd__config__entry('puppet_service_autofs')
              .with_content(<<~CONTENT)
                #
                # This section is auto generated from a user supplied Hash
                [autofs]
                key1 = value1
                key2 = value2
                #
              CONTENT
          }
        end
      end
    end
  end
end
