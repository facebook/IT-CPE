# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

class Chef
  class Recipe
    # CPE is our namespace for any CPE tools
    class CPE
      def self.app_paths(bundle_identifier)
        # Search Spotlight for matching identifier, strip newlines
        Mixlib::ShellOut.new(
          "/usr/bin/mdfind \"kMDItemCFBundleIdentifier==#{bundle_identifier}\""
        ).run_command.stdout.split('\n').map!(&:chomp)
      end

      def self.installed?(bundle_identifier)
        paths = app_paths(bundle_identifier)
        !paths.empty?
      end
    end
  end
end
