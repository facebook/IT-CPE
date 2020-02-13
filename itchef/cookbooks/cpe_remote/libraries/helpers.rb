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
  module Remote
    def gen_url(path, file)
      http = node['cpe_remote']['http']
      uri = http ? 'http' : 'https'
      url = "#{uri}://#{node['cpe_remote']['base_url']}/#{path}/#{file}"
      Chef::Log.info("Source URL: #{url}")
      url
    end

    def valid_url?(url)
      require 'chef/http/simple'
      http = Chef::HTTP::Simple.new(url)
      # CHEF-4762: we expect a nil return value from Chef::HTTP for a
      # "200 Success" response and false for a "304 Not Modified" response
      headers = auth_headers(url, 'HEAD')
      http.head(url, headers)
      true
    rescue StandardError
      Chef::Log.warn("INVALID URL GIVEN: #{url}")
      false
    end

    def auth_headers(url, method)
      if defined?(CPE::Distro)
        CPE::Distro.auth_headers(url, method)
      else
        {}
      end
    rescue StandardError
      Chef::Log.warn('Building auth headers failed')
      {}
    end

    def validate_checksum(path, checksum)
      # Comparing the Checksum Provided to the file downloaded
      checksum_ondisk = Chef::Digester.checksum_for_file(path)
      if checksum != checksum_ondisk
        Chef::Log.warn(
          "Path:#{path} provided checksum #{checksum} != " +
          "File On Disk checksum #{checksum_ondisk}",
        )
        return false
      end
      true
    rescue StandardError => e
      Chef::Log.warn("cpe_remote/validate_checksum failed with:#{e.message}")
      false
    end
  end
end
