# rubocop:disable Chef/Meta/MetadataExists
require './spec/itchef_spec'
require './chef/itchef/spec/itchef_node_helpers'

recipe 'cpe_windows_update_for_business::default',
       :unsupported => [:mac_os_x] do |tc|
  include FB::Spec::Helpers

  context 'on a non-Windows platform' do
    let(:chef_run) do
      tc.chef_run do |node|
        ITChefSpecHelpers.setup_cpe_node(node)
        node.stub(:centos_max_version?).and_return(false)
        node.stub(:finance?).and_return(false)
      end
    end

    it 'converges without error' do
      expect { chef_run.converge(described_recipe) }.not_to raise_error
    end
  end
end
