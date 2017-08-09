module CPE
  module Remote
    def gen_url(server, path, file)
      return "https://#{server}/#{path}/#{file}"
    end

    def valid_url?(url)
      require 'chef/http/simple'
      http = Chef::HTTP::Simple.new(url)
      # CHEF-4762: we expect a nil return value from Chef::HTTP for a
      # "200 Success" response and false for a "304 Not Modified" response
      http.head(url)
      true
    rescue
      Chef::Log.warn("INVALID URL GIVEN: #{url}")
      false
    end
  end
end
