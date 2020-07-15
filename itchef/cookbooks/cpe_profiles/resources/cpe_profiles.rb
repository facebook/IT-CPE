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

# Cookbook Name:: cpe_profiles
# Resource:: cpe_profiles

resource_name :cpe_profiles
provides :cpe_profiles, :os => 'darwin'
default_action :run

action :run do
  map = node['cpe_profiles']['cookbook_map']
  default = node['cpe_profiles']['default_cookbook']
  prefix = node['cpe_profiles']['prefix']
  profiles.each do |k, v|
    # see if this prefix is overridden with a cookbook or fallback to default
    cookbook = map.key?(k) ? map[k] : default

    # read the 'destination' cookbook prefix
    cb_prefix = node[cookbook]['prefix']

    # replace the prefix name in the main Hash key
    new_prefix = k.sub(prefix, cb_prefix)

    # inject newly replaced profile into destination prefix
    node.default[cookbook][new_prefix] = profile_prefix_sub(v, cb_prefix)
  end
end

action_class do
  def profiles
    node['cpe_profiles'].to_h.reject do |k, v|
      [
        'prefix',
        'default_cookbook',
        'cookbook_map',
      ].include?(k) || !v.is_a?(Hash)
    end
  end

  def profile_prefix_sub(profile, cb_prefix)
    # rewrite prefix for profile
    new_profile = payload_prefix_sub(profile, cb_prefix)

    # rewrite prefix for each payload
    new_profile['PayloadContent'] = new_profile['PayloadContent'].map do |p|
      payload_prefix_sub(p, cb_prefix)
    end

    new_profile
  end

  def payload_prefix_sub(payload, cb_prefix)
    unless payload.key?('PayloadIdentifier')
      Chef::Log.warn(
        "#{cookbook_name}: payload does not contain"\
        " a ProfileIdentifier key: #{payload}",
      )
      return payload
    end

    prefix = node['cpe_profiles']['prefix']
    new_payload = payload.clone

    new_payload['PayloadIdentifier'] = new_payload['PayloadIdentifier'].sub(
      prefix, cb_prefix
    )

    new_payload
  end
end
