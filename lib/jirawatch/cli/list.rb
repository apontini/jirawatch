module Jirawatch
  module CLI
    class List < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand
      
      def call(*)

      end
    end
  end
end
