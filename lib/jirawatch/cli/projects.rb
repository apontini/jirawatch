module Jirawatch
  module CLI
    class Projects < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      def call(*)
        puts "Id\tKey\tName\n\n"
        @jira_client.Project.all.each do |project|
          puts "#{project.id}\t#{project.key}\t#{project.name}"
        end
      end

    end
  end
end
