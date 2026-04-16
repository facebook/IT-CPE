# rubocop:disable Chef/Meta/MetadataExists
require './spec/itchef_spec'

recipe 'cpe_gnome_software::default', :unsupported => [:mac_os_x] do |tc|
  include FB::Spec::Helpers

  context 'on a Fedora host' do
    let(:chef_run) do
      tc.chef_run do |node|
        node.default['hostnamectl']['operating_system'] = 'CentOS Linux'
        node.stub(:fedora?).and_return(true)
      end
    end

    it 'converges without error' do
      expect { chef_run.converge(described_recipe) }.not_to raise_error
    end

    it 'creates the cpe_gnome_software resource' do
      chef_run.converge(described_recipe)
      resource = chef_run.find_resource(
        'cpe_gnome_software', 'Configure GNOME Software'
      )
      expect(resource).not_to be_nil
    end
  end

  context 'on a non-Fedora host' do
    let(:chef_run) do
      tc.chef_run do |node|
        node.default['hostnamectl']['operating_system'] = 'CentOS Linux'
        node.stub(:fedora?).and_return(false)
      end
    end

    it 'converges without error (returns early)' do
      expect { chef_run.converge(described_recipe) }.not_to raise_error
    end

    it 'does not create the cpe_gnome_software resource' do
      chef_run.converge(described_recipe)
      resource = chef_run.find_resource(
        'cpe_gnome_software', 'Configure GNOME Software'
      )
      expect(resource).to be_nil
    end
  end
end
