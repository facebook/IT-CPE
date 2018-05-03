module CPE
  # Various utility grab-bag.
  module Utils
    def root_owner
      value_for_platform(
        'windows' => { 'default' => 'Administrator' },
        'default' => 'root',
      )
    end

    def root_group
      value_for_platform(
        ['openbsd', 'freebsd', 'mac_os_x'] => { 'default' => 'wheel' },
        'windows' => { 'default' => 'Administrators' },
        'default' => 'root',
      )
    end
  end
end

Chef::Recipe.send(:include, ::CPE::Utils)
Chef::Resource.send(:include, ::CPE::Utils)
Chef::Provider.send(:include, ::CPE::Utils)
