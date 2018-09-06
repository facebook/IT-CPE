# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#

# Do osquery stuff
module Osquery
  # Execute a query
  # @param [string] query
  def self.query(query, platform = 'posix', format = 'json')
    if platform == 'windows'
      @osquery_bin = 'C:\\ProgramData\\osquery\\osqueryi.exe'
    else
      @osquery_bin = ''
      [
        '/usr/bin/osqueryi',
        '/usr/local/bin/osqueryi',
      ].each do |path|
        if File.exist?(path)
          @osquery_bin = path
          break
        end
      end
    end

    @query = query.tr("\n", ' ')

    unless File.exist?(@osquery_bin)
      Chef::Log.info('cpe_utils osquery: could not find osqueryi')
      return []
    end
    results = []
    begin
      osquery_cmd = "#{@osquery_bin} --disable_extensions \"#{@query}\""
      if format == 'json'
        response = shell_out(
          "#{osquery_cmd} --json",
        ).stdout
        results = JSON.parse(response)
      elsif format == 'list'
        results = shell_out(
          "#{osquery_cmd} --list --header=0",
        ).stdout.split("\n")
      end
    rescue JSON::ParserError => e
      Chef::Log.info("cpe_utils osquery: In osquery.rb Error: #{e.message}")
      results = []
    rescue Mixlib::ShellOut::CommandTimeout => e
      Chef::Log.warn("cpe_utils osquery: osquery timeout: #{e.message}")
      results = []
    end
    return results
  end

  def self.app_name(app_name)
    # Use osquery to find apps that start with app_name
    query =
      'select name, bundle_name, bundle_identifier, bundle_version, ' +
      "bundle_short_version, path from apps where name like \"#{app_name}%\""
    self.query(query)
  end

  def self.homebrew_pkg(pkg_name)
    # Use osquery to find homebrew packages that look like pkg_name
    query =
      'select version, path from homebrew_packages where name ' +
      "like \"#{pkg_name}%\""
    self.query(query)
  end
end
