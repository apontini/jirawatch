module Jirawatch
  module CLI
    class Issues < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :project, desc: "Id or key of the project which issues have to be listed"
      option :all, type: :boolean, default: false, aliases: ["-a"], desc: "List every issue on Jira"

      def call(project: nil, **options)
        if options.fetch(:all)
          puts "WARNING: this could take a while, are you sure? [y/N]"
          @jira_client.Issue.all if STDIN.gets.chomp.downcase.eql? 'y'
        else
          if project
            begin
              puts "Id\t\tKey\t\tType\t\tSummary\n\n"
              @jira_client.Project.find(project).issues.each do |issue|
                puts "#{issue.id}\t\t#{issue.key}\t\t#{issue.fields['issuetype']['name']}\t\t#{issue.fields['summary']}"
              end
            rescue JIRA::HTTPError => e
              puts e.response.body

            rescue StandardError => e
              puts e.message
            end
          else
            puts "Please specify the project ID"
          end
        end
      end

    end
  end
end
