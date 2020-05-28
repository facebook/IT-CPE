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

require 'chefspec'
require_relative '../libraries/flatpak_helpers'
require_relative '../../cpe_helpers/libraries/cpe_helpers'

describe CPE::Flatpak do
  let(:flatpak) { Class.new { extend CPE::Flatpak } }
  context 'when on linux' do
    before do
      allow(Chef::Log).to receive(:debug)
      allow(flatpak).to receive(:chef_cache).and_return('/var/chef/cache')
      allow(CPE::Helpers).to receive(:linux?).and_return(true)
    end
    it 'chef_cache should be /var/chef/cache' do
      expect(flatpak.chef_cache).to eq('/var/chef/cache')
    end
    it 'flatpak_remotes_receipt_path should be set correctly' do
      expect(flatpak.flatpak_remotes_receipt_path).to eq(
        '/var/chef/cache/cpe_flatpak/remotes.json',
      )
    end
    it 'flatpak_packages_receipt_path should be set correctly' do
      expect(flatpak.flatpak_packages_receipt_path).to eq(
        '/var/chef/cache/cpe_flatpak/packages.json',
      )
    end
    it 'flatpak_remote_add should be executing flatpak remote-add' do
      expect(flatpak.flatpak_remote_add(
               'flathub',
               'https://flathub.org/repo/flathub.flatpakrepo',
      )).to eq(
        '/usr/bin/flatpak remote-add --if-not-exists ' +
        'flathub https://flathub.org/repo/flathub.flatpakrepo',
      )
    end
    it 'flatpak_remote_remove should be executing flatpak remote-delete' do
      expect(flatpak.flatpak_remote_remove(
               'flathub',
      )).to eq(
        '/usr/bin/flatpak remote-delete flathub',
      )
    end
    it 'flatpak_install should be executing flatpak install' do
      expect(flatpak.flatpak_install(
               'flathub',
               'com.visualstudio.code',
      )).to eq(
        '/usr/bin/flatpak install -y flathub com.visualstudio.code',
      )
    end
    it 'flatpak_remove should be executing flatpak uninstall' do
      expect(flatpak.flatpak_remove(
               'com.visualstudio.code',
      )).to eq(
        '/usr/bin/flatpak uninstall -y --force-remove com.visualstudio.code',
      )
    end
    it 'flatpak_command should be executing flatpak run' do
      expect(flatpak.flatpak_command(
               'run com.visualstudio.code',
      )).to eq(
        '/usr/bin/flatpak run com.visualstudio.code',
      )
    end
    context 'when the flathub repo is installed' do
      before do
        allow(flatpak).to receive(:shell_out).
          with('/usr/bin/flatpak remotes -d').
          and_return(
            double(
              :stdout =>
              "flathub\tFlathub\thttps://dl.flathub.org/repo/\t-\t1\tsystem\n",
            ),
          )
      end
      it 'repo_installed? should be returning true' do
        expect(flatpak.repo_installed?('flathub')).to eq(true)
      end
    end
    context 'when the flathub repo is not installed' do
      before do
        allow(flatpak).to receive(:shell_out).
          with('/usr/bin/flatpak remotes -d').
          and_return(
            double(
              :stdout =>
              "flatpak\tFlatpak\thttps://dl.flatpak.org/repo/\t-\t1\tsystem\n",
            ),
          )
      end
      it 'repo_installed? should be returning false' do
        expect(flatpak.repo_installed?('flathub')).to eq(false)
      end
    end
    context 'when the VisualStudio Code package is installed' do
      before do
        allow(flatpak).to receive(:shell_out).
          with('/usr/bin/flatpak list').
          and_return(double(:stdout => "com.visualstudio.code/x86_64/stable\n"))
      end
      it 'pkg_installed? should be returning true' do
        expect(flatpak.pkg_installed?('com.visualstudio.code')).to eq(true)
      end
    end
    context 'when the VisualStudio Code package is not installed' do
      before do
        allow(flatpak).to receive(:shell_out).
          with('/usr/bin/flatpak list').
          and_return(double(:stdout => "com.spotify.Client/x86_64/stable\n"))
      end
      it 'pkg_installed? should be returning false' do
        expect(flatpak.pkg_installed?('com.visualstudio.code')).to eq(false)
      end
    end
  end
end
