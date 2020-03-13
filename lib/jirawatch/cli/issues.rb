module Jirawatch
  module CLI
    class Issues < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :project, required: true, desc: "Id or key of the project which issues have to be listed"

      def call(project: nil, **options)
        puts "Id\t\tKey\t\tType\t\tSummary\n\n"
        @jira_client.Project.find(project).issues.each do |issue|
          puts "#{issue.id}\t\t#{issue.key}\t\t#{issue.fields['issuetype']['name']}\t\t#{issue.fields['summary']}"
        end
      end
    end
  end
end
