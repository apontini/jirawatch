require 'tty-editor'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :issue_key, required: true, desc: "The issue key that you want to track time for"
      option :started_at, aliases: ["-t"], desc: "Issue track starting time with a HH:mm format"

      def call(issue_key:, **options)
        @jira_client.Issue.find(issue_key) # Fails if issue doesn't exist

        puts "Logging time for #{issue_key}..."
        started_at = Time.parse(options.fetch(:started_at, Time.now.to_s))
        puts started_at

        begin
          loop do
            sleep 1
          end
        rescue Interrupt
          time_spent = (Time.now - started_at).floor

          # Jira work logs have minute sensitivity thus API calls will fail with a time spent
          # which is less than 60 seconds

          fail! "Jira can't log less than 60 seconds of work" if time_spent < 60

          TTY::Editor.open(
              Jirawatch.configuration.template_track_file % started_at.to_i,
              content: "\n" +
                  "# You spent #{(time_spent / 60).floor} minutes on this issue" +
                  "# Write here your work log description\n" +
                  "# If you leave this empty, no work log will be saved"
          )

          worklog_lines = []
          File.readlines(Jirawatch.configuration.template_track_file % started_at.to_i).each do |line|
            worklog_lines << line unless line.start_with?("#") or line.strip.empty?
          end

          @jira_client.Issue.find(issue_key).worklogs.build.save(
              {
                  timeSpentSeconds: time_spent,
                  started: started_at.strftime("%Y-%m-%dT%H:%M:%S.%L%z"),
                  comment: worklog_lines.join("\n")
              }
          ) unless worklog_lines.empty?

          puts "Worklog was empty, time was not tracked" if worklog_lines.empty?

          File.delete Jirawatch.configuration.template_track_file % started_at.to_i
        end
      end
    end
  end
end
