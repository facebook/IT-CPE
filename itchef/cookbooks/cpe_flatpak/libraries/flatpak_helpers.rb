# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module CPE
  module Flatpak
    def manage
      @manage ||= node['cpe_flatpak']['manage']
    end

    def chef_cache
      Chef::Config[:file_cache_path]
    end

    def flatpak_remotes_receipt_path
      "#{chef_cache}/cpe_flatpak/remotes.json"
    end

    def flatpak_remotes_receipt
      return [] unless ::File.exist?(flatpak_remotes_receipt_path)
      Chef::JSONCompat.from_json(::File.read(flatpak_remotes_receipt_path))
    rescue StandardError
      []
    end

    def flatpak_packages_receipt_path
      "#{chef_cache}/cpe_flatpak/packages.json"
    end

    def flatpak_packages_receipt
      return [] unless ::File.exist?(flatpak_packages_receipt_path)
      Chef::JSONCompat.from_json(::File.read(flatpak_packages_receipt_path))
    rescue StandardError
      []
    end

    def as_user(cmd)
      "/usr/bin/su #{CPE::Helpers.console_user} -l -c '#{cmd}'"
    end

    def flatpak_remote_add(remote, url)
      Chef::Log.debug("Running flatpak_remote_add on #{remote}")
      "/usr/bin/flatpak remote-add --if-not-exists #{remote} #{url}"
    end

    def flatpak_remote_remove(remote)
      Chef::Log.debug("Running flatpak_remote_remove on #{remote}")
      "/usr/bin/flatpak remote-delete #{remote}"
    end

    def flatpak_install(remote, pkg)
      # To install a Flatpak package
      Chef::Log.debug("Running flatpak_install #{pkg}")
      "/usr/bin/flatpak install -y #{remote} #{pkg}"
    end

    def flatpak_run(cmd)
      # To run a Flatpak package
      Chef::Log.debug("Running flatpak_run #{cmd}")
      as_user("/usr/bin/flatpak run #{cmd}")
    end

    def flatpak_remove(pkg)
      # To uninstall a Flatpak package
      Chef::Log.debug("Running flatpak_remove #{pkg}")
      "/usr/bin/flatpak uninstall -y --force-remove #{pkg}"
    end

    def flatpak_command(cmd)
      # For running arbitrary flatpak commands.
      Chef::Log.debug("Running flatpak #{cmd}")
      "/usr/bin/flatpak #{cmd}"
    end

    def repo_installed?(repo_name)
      return false unless repo_name
      repos = shell_out('/usr/bin/flatpak remotes -d').stdout.to_s
      repos.split("\n").any? { |r| r.split("\t")[0].include?(repo_name) }
    end

    def pkg_installed?(pkg)
      return false unless pkg
      pkgs = shell_out('/usr/bin/flatpak list').stdout.to_s
      pkgs.split("\n").any? { |p| p.include?(pkg) }
    end
  end
end
