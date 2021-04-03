module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      option :day, aliases: ["-d"], desc: "Specify the day which worklogs you want to list"

      def call(issue_key:, **options)
        puts @jira_client.worklogs
      end

    end
  end
end
