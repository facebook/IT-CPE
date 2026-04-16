# rubocop:disable Chef/Meta/MetadataExists
require './spec/itchef_spec'

recipe 'cpe_win_telemetry::default', :unsupported => [:mac_os_x] do |tc|
  include FB::Spec::Helpers

  context 'on a Linux host' do
    let(:chef_run) do
      tc.chef_run do |node|
        node.default['hostnamectl']['operating_system'] = 'CentOS Linux'
        node.stub(:windows?).and_return(false)
      end
    end

    it 'converges without error (returns early)' do
      expect { chef_run.converge(described_recipe) }.not_to raise_error
    end
  end
end
