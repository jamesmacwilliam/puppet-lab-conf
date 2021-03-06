require 'spec_helper'

describe 'apache::mod::negotiation', type: :class do
  it_behaves_like 'a mod class, without including apache'
  describe 'OS independent tests' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystem: 'Debian',
        kernel: 'Linux',
        lsbdistcodename: 'jessie',
        operatingsystemrelease: '8',
        concat_basedir: '/dne',
        id: 'root',
        path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        is_pe: false,
      }
    end

    context 'default params' do
      it { is_expected.to contain_class('apache') }
      it do
        is_expected.to contain_file('negotiation.conf').with(ensure: 'file',
                                                             content: 'LanguagePriority en ca cs da de el eo es et fr he hr it ja ko ltz nl nn no pl pt pt-BR ru sv zh-CN zh-TW
ForceLanguagePriority Prefer Fallback
')
      end
    end

    context 'with force_language_priority parameter' do
      let :params do
        { force_language_priority: 'Prefer' }
      end

      it do
        is_expected.to contain_file('negotiation.conf').with(ensure: 'file',
                                                             content: %r{^ForceLanguagePriority Prefer$})
      end
    end

    context 'with language_priority parameter' do
      let :params do
        { language_priority: ['en', 'es'] }
      end

      it do
        is_expected.to contain_file('negotiation.conf').with(ensure: 'file',
                                                             content: %r{^LanguagePriority en es$})
      end
    end
  end
end
