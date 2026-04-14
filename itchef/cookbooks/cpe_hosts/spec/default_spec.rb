# rubocop:disable Chef/Meta/MetadataExists
require './spec/itchef_spec'
require './chef/itchef/spec/itchef_node_helpers'

recipe 'cpe_hosts::default', :unsupported => [:mac_os_x] do |tc|
  include FB::Spec::Helpers

  context 'with no extra entries' do
    let(:chef_run) do
      tc.chef_run do |node|
        ITChefSpecHelpers.setup_cpe_node(node)
        node.stub(:centos_max_version?).and_return(false)
        node.stub(:finance?).and_return(false)
      end
    end

    before do
      allow(::File).to receive(:readlines).and_call_original
      allow(::File).to receive(:readlines).with('/etc/hosts').
        and_return(["127.0.0.1 localhost\n"])
    end

    it 'converges without error' do
      expect { chef_run.converge(described_recipe) }.not_to raise_error
    end

    it 'creates the cpe_hosts resource' do
      chef_run.converge(described_recipe)
      resource = chef_run.find_resource('cpe_hosts', 'Managing hosts file')
      expect(resource).not_to be_nil
    end
  end

  context 'with extra entries and manage_by_line' do
    let(:chef_run) do
      tc.chef_run do |node|
        ITChefSpecHelpers.setup_cpe_node(node)
        node.stub(:centos_max_version?).and_return(false)
        node.stub(:finance?).and_return(false)
        node.default['cpe_hosts']['extra_entries'] = {
          '10.0.0.1' => ['myhost.example.com', 'myhost'],
        }
        node.default['cpe_hosts']['manage_by_line'] = true
      end
    end

    before do
      allow(::File).to receive(:readlines).and_call_original
      allow(::File).to receive(:readlines).with('/etc/hosts').
        and_return([
          "127.0.0.1 localhost\n",
          "# Chef Managed old entry\n",
        ])
    end

    it 'converges without error' do
      expect { chef_run.converge(described_recipe) }.not_to raise_error
    end
  end
end
