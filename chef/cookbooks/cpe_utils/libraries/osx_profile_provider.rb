#
# Author:: Mike Dodge (<mikedodge04@gmail.com>)
# Copyright:: Copyright (c) 2015 Facebook, Inc.
# License:: Apache License, Version 2.0
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

class Chef
  class Provider
    class OsxProfile

      def load_current_resource
        @current_resource = Chef::Resource::OsxProfile.new(@new_resource.name)
        @current_resource.profile_name(@new_resource.profile_name)

        all_profiles = get_installed_profiles
        @new_resource.profile(
          @new_resource.profile ||
          @new_resource.profile_name
        )

        @new_profile_hash = get_profile_hash(@new_resource.profile)
        @new_profile_hash["PayloadUUID"] =
          config_uuid(@new_profile_hash) if @new_profile_hash

        if @new_profile_hash
          @new_profile_identifier = @new_profile_hash["PayloadIdentifier"]
        else
          @new_profile_identifier = @new_resource.identifier ||
            @new_resource.profile_name
        end

        current_profile = nil
        if all_profiles &&
          !all_profiles.empty? &&
          all_profiles.key?('_computerlevel')
          current_profile = all_profiles['_computerlevel'].find do |item|
            item['ProfileIdentifier'] == @new_profile_identifier
          end
        end
        @current_resource.profile(current_profile)
      end
    end
  end
end
