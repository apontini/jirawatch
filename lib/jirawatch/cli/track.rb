require 'jirawatch/cli/authenticated_command'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :issue_key, required: true, desc: "The issue key that you want to track time for"

      def call(issue_key:, **options)
        begin
          @jira_client.Issue.find(issue_key)
        rescue JIRA::HTTPError => e
          puts e.response.body
          return
        end

        puts "Started loggin time for #{issue_key}"
        started_at = Time.now

        begin
          loop do
            sleep 1
          end
        rescue Interrupt
          time_spent = (Time.now - started_at).floor

          # Jira work logs have minute sensitivity thus API calls will fail with a time spent
          # which is less than 60 seconds
          return if time_spent < 60

          puts "\nLogging completed, you spent #{(time_spent / 60).floor} minutes on this issue, do you want to log it? [Y/n]"
          @jira_client.Issue.find(issue_key).worklogs.build.save(
              {
                  timeSpentSeconds: time_spent,
                  started: started_at.strftime("%Y-%m-%dT%H:%M:%S.%L%z")
              }
          ) if STDIN.gets.chomp.downcase.eql? 'y'
        end
      end
    end
  end
end
