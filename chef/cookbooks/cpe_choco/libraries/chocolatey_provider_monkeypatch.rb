# Copyright (c) Facebook, Inc. and its affiliates.
#
# Some explanation behind the motivation for this monkeypatch:
# * Need to support pre-release versions for the osquery team so they can shard
#   out new versions to the fleet.
# ** In order to support this, the `available_packages` method call needs to
#    support the `--prerelease` flag such that chocolatey knows to also list
#    packages in the feed that contain non-production versions.
# * The order with which the provider appends flags is incorrect:
# ** Chocolatey would add an option like `--ignore-checksums` to the end of the
#    command line, which chocolatey would interpret as the name of a package
#    instead of an optional flag.
# rubocop:disable Metrics/LineLength

class Chef
  class Provider
    class Package
      class Chocolatey
        # Available packages in chocolatey as a Hash of names mapped to versions
        # If pinning a package to a specific version, filter out all non matching versions
        # (names are downcased for case-insensitive matching)
        #
        # @return [Hash] name-to-version mapping of available packages
        def available_packages
          @available_packages ||=
            begin
              cmd = ["list -r #{package_name_array.join ' '}"]
              cmd.push('--prerelease') if new_resource.prerelease # added
              cmd.push("-source #{new_resource.source}") if new_resource.source
              raw = parse_list_output(*cmd)
              raw.keys.each_with_object({}) do |name, available|
                available[name] = desired_name_versions[name] || raw[name]
              end
            end
        end

        # Helper to construct optional args out of new_resource
        #
        # @param include_source [Boolean] should the source parameter be added
        # @return [String] options from new_resource or empty string
        def cmd_args(include_source: true)
          cmd_args = []
          cmd_args.push('--prerelease') if new_resource.prerelease # added
          cmd_args.push(new_resource.options) if new_resource.options # added
          cmd_args.push("-source #{new_resource.source}") if new_resource.source && include_source
          args_to_string(*cmd_args)
        end

        private

        # Helper to convert choco.exe list output to a Hash
        # (names are downcased for case-insenstive matching)
        #
        # @param cmd [String] command to run
        # @return [Hash] list output converted to ruby Hash
        def parse_list_output(*args)
          parsed_hash = {}
          choco_command(*args).stdout.each_line do |line|
            next if line.start_with?('Chocolatey v')
            name, version = line.split('|')
            parsed_hash[name.downcase] = version ? version.chomp : nil
          end
          parsed_hash
        end
      end
    end
  end
end

class Chef
  class Resource
    class ChocolateyPackage
      property :prerelease, [TrueClass, FalseClass], :default => false # added
    end
  end
end
