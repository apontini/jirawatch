require 'jirawatch/cli/authenticated_command'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      def call(*)
        puts 'tracking here'
      end
    end
  end
end
