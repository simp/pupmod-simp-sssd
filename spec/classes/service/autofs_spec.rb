require 'spec_helper'

describe 'sssd::service::autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        context 'with defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment('sssd_autofs.service').without_content(%r(=\s*$)) }
        end
        context 'with custom options' do
          let(:params) {{ 
            'custom_options' =>  { 'key1' => 'value1', 'key2' => 'value2'}
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment('sssd_autofs.service').with_content(<<-EOM.gsub(/^\s+/,''))
            #
            # This section is auto generate from a user supplied Hash
            [autofs]
            key1 = value1
            key2 = value2
            #
          EOM
          }
        end 
      end
    end
  end
end
