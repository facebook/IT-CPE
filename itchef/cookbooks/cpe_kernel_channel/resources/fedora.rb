# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Cookbook Name:: cpe_kernel_channel
# Resource:: fedora

resource_name :cpe_kernel_channel_fedora
provides :cpe_kernel_channel, :platform => 'fedora'
default_action :update

action :update do
  return unless node['cpe_kernel_channel']['enable']

  repo = node['cpe_kernel_channel']['repo']

  # Asking for the Fedora kernel on Fedora; no-op
  return if repo == 'fedora'

  # Otherwise, fail unless the CentOS repo is specified
  unless repo == 'centos'
    fail 'Only CentOS repositories are supported at the moment'
  end

  cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial' do
    source 'centos_kernel/RPM-GPG-KEY-centosofficial'
    owner 'root'
    group 'root'
    mode '0644'
  end

  release = node['cpe_kernel_channel']['release']

  yum_repository 'CentOS-BaseOS' do
    description "CentOS-#{release} - Base"
    mirrorlist 'http://mirrorlist.centos.org/' +
      "?release=#{release}&arch=$basearch&repo=BaseOS"
    fastestmirror_enabled true
    gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial'
    includepkgs 'kernel*,kexec-tools'
    skip_if_unavailable true
  end

  # make sure we have a CentOS kernel installed
  kernel_ver = node['cpe_kernel_channel']['kernel_version']
  if kernel_ver
    package ['kernel', 'kernel-devel'] do
      only_if { ::Dir.glob("/boot/vmlinuz-#{kernel_ver}*.el*.x86_64").empty? }
      version [kernel_ver, kernel_ver]
    end
  end
end
