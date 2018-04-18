module CPE
  module Remote
    def gen_url(path, file)
      url = "https://#{node['cpe_remote']['base_url']}/#{path}/#{file}"
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
      CPE::Distro.auth_headers(url, method)
    rescue StandardError
      Chef::Log.warn('Building auth headers failed')
      {}
    end
  end
end
