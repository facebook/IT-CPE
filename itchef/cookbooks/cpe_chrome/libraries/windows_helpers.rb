module CPE
  module WindowsChromeHelpers
    # Updates CPE::ChromeManagement::KnownSettings::GENERATED to contain
    # configured values and returns a list of policies that were updated.
    def set_reg_settings(node)
      reg_settings = []
      node['cpe_chrome']['profile'].each do |setting_key, setting_value|
        next if setting_value.nil?
        setting = CPE::ChromeManagement::KnownSettings::GENERATED.fetch(
          setting_key,
          nil,
        )
        unless setting
          next
        end

        if setting_value.is_a?(Hash)
          next if setting_value.empty?
          setting.value = setting_value.to_json
        else
          setting.value = setting_value
        end

        reg_settings << setting
      end
      reg_settings
    end

    def policies_to_remove(using_reg_file)
      doomed_policies = {}
      CPE::ChromeManagement::KnownSettings::GENERATED.each do |name, obj|
        if obj.is_a?(WindowsChromeFlatSetting)
          begin
            current_values = registry_get_values(obj.registry_location).
                             select { |k, _| name == k[:name] }
          rescue Chef::Exceptions::Win32RegKeyMissing
            next
          end
          # when using registry_key resource we only need to delete the key if
          # a current value is set and we are not explicity setting a new value
          next unless current_values.any? || using_reg_file
          next unless obj.value.nil? || using_reg_file

          # when using a reg file, we need to delete values even if we are overwriting them
          # due to how the idempotency check works.
          next if using_reg_file && obj.value.nil? && current_values.empty?

          next if current_values == obj.to_chef_reg_provider
          doomed_policies[obj] = current_values
        elsif obj.is_a?(WindowsChromeIterableSetting)
          if using_reg_file
            begin
              current_values = registry_get_values(obj.registry_location)
            rescue Chef::Exceptions::Win32RegKeyMissing
              next
            end

            # delete existing iterable settings if any subvalue differs from
            # expected if we are using a regfile to apply changes since it will
            # not delete unmanaged keys automatically
            unless policy_values_match(current_values, obj.to_chef_reg_provider)
              doomed_policies[obj] = nil
            end
          elsif registry_key_exists?(obj.registry_location) && obj.value.nil?
            # delete existing iterable settings if we are not explicitly
            # managing them if we are using the registry_key resource
            doomed_policies[obj] = current_values
          end
        end
      end
      doomed_policies
    end

    def gen_reg_file_settings(settings_to_delete, reg_settings)
      delete_policies = { :flat => Hash.new([]), :iterable => [] }
      settings_to_delete.each do |policy, vals|
        if policy.is_a?(WindowsChromeIterableSetting)
          # delete the full key
          delete_policies[:iterable] << policy.registry_location
        elsif policy.is_a?(WindowsChromeFlatSetting)
          # delete only the managed values
          delete_policies[:flat][policy.registry_location] += vals
        end
      end

      create_policies = Hash.new([])
      reg_settings.each do |policy|
        create_policies[policy.registry_location] += policy.to_chef_reg_provider
      end

      { :delete => delete_policies, :create => create_policies }
    end

    def verify_update_needed(settings)
      # an update is needed if any keys should be deleted
      return true if settings[:delete].each_value.map { |v| !v.empty? }.any?
      # an update is needed if any keys we are manageing do not exist
      return true if settings[:create].keys.any? { |k| !registry_key_exists?(k) }
      false
    end

    def policy_values_match(a, b)
      a.sort { |x, y| x[:name] <=> y[:name] } ==
        b.sort { |x, y| x[:name] <=> y[:name] }
    end
  end
end
