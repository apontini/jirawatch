require 'tty-editor'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :issue_key, required: true, desc: "Issue key that you want to track time for"
      option :tracking_started_at, aliases: ["-t"], desc: "Specify when you started working on this issue with a HH:mm format"
      option :worklog_message, aliases: ["-m"], desc: "Specify a work log message"

      def call(issue_key:, **options)
        @jira_client.Issue.find(issue_key) # Fails if issue doesn't exist

        tracking_started_at = Time.parse(options.fetch(:tracking_started_at, Time.now.to_s))
        tracking_paused_at = 0
        tracking_restarted_at = tracking_started_at.to_i
        partial_time_spent = 0

        puts "Logging time for #{issue_key}..."
        puts tracking_started_at
        puts
        puts "Press CTRL-P to pause/restart tracking time"
        puts "Press CTRL-C to stop tracking time"

        reader = TTY::Reader.new
        reader.on(:keyctrl_p) do
          if tracking_paused_at == 0
            tracking_paused_at = Time.now.to_i
            partial_time_spent += tracking_paused_at - tracking_restarted_at
            time_unit = partial_time_spent / 60 == 1 ? "minute" : "minutes"
            puts
            puts "Tracking has been paused with #{partial_time_spent / 60} #{time_unit} logged"
          else
            tracking_paused_at = 0
            tracking_restarted_at = Time.now.to_i
            puts
            puts "Tracking has been restarted"
          end
        end

        begin
          loop do
            reader.read_line("")
          end
        rescue Interrupt
          total_time_spent = partial_time_spent + (Time.now.to_i - tracking_restarted_at)

          # Jira work logs have minute sensitivity thus API calls will fail with a time spent
          # which is less than 60 seconds

          fail! "Jira can't log less than 60 seconds of work" if total_time_spent < 60

          worklog_file = Jirawatch.configuration.template_worklog_file % tracking_started_at.to_i
          worklog_lines = []

          File.write worklog_file, options.fetch(:worklog_message) if options.key? :worklog_message
          TTY::Editor.open(
              worklog_file,
              content: "\n" +
                  "# You spent #{total_time_spent / 60} minutes on this issue\n" +
                  "# Write here your work log description\n" +
                  "# If you leave this empty, no work log will be saved"
          ) unless options.key? :worklog_message

          File.readlines(Jirawatch.configuration.template_worklog_file % tracking_started_at.to_i).each do |line|
            worklog_lines << line unless line.start_with?("#") or line.strip.empty?
          end

          @jira_client.Issue.find(issue_key).worklogs.build.save(
              {
                  timeSpentSeconds: total_time_spent,
                  started: tracking_started_at.strftime("%Y-%m-%dT%H:%M:%S.%L%z"),
                  comment: worklog_lines.join("\n")
              }
          ) unless worklog_lines.empty?

          puts "Worklog was empty, time was not tracked" if worklog_lines.empty?

          File.delete worklog_file
        end
      end
    end
  end
end
