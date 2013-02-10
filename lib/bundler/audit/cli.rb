#
# Copyright (c) 2013 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# bundler-audit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bundler-audit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bundler-audit.  If not, see <http://www.gnu.org/licenses/>.
#

require 'bundler/audit/database'
require 'bundler/audit/version'

require 'bundler/vendored_thor'
require 'bundler'

module Bundler
  module Audit
    class CLI < Thor

      default_task :check
      map '--version' => :version

      desc 'check', 'Checks the Gemfile.lock for insecure dependencies'
      method_option :verbose, :flag => '-v'

      def check
        environment = Bundler.load
        database    = Database.new
        vulnerable  = false

        database.check_bundle(environment) do |advisory|
          vulnerable = true

          print_advisory advisory
        end

        if vulnerable
          say "Unpatched versions found!", :red
          return -1
        else
          say "No unpatched versions found", :green
        end
      end

      desc 'version', 'Prints the bundler-audit version'
      def version
        database = Database.new

        puts "#{File.basename($0)} #{VERSION} (advisories: #{database.size})"
      end

      protected

      def print_advisory(advisory)
        say "CVE: ", :red
        say advisory.cve

        say "URL: ", :red
        say advisory.url

        if options.verbose?
          say "Description:", :red
          say

          print_wrapped advisory.description, :indent => 2
          say
        else

          say "Title: ", :red
          say advisory.title
        end

        say "Patched Versions: ", :red
        say advisory.uneffected_versions.join(', ')
        say
      end

    end
  end
end