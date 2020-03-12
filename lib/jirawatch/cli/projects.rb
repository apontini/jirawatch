module Jirawatch
  module CLI
    class Projects < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      def call(*)
        @jira_client.Project.all.each do |project|
          puts "#{project.id} - #{project.name}"
        end
      end

    end
  end
end
