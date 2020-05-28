require 'tty-editor'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :issue_key, required: true, desc: "Issue key that you want to track time for"
      option :time_started_at, aliases: ["-t"], desc: "Specify when you started working on this issue with a HH:mm format"
      option :worklog_message, aliases: ["-m"], desc: "Specify a work log message"

      def call(issue_key:, **options)
        @jira_client.Issue.find(issue_key) # Fails if issue doesn't exist

        time_started_at = Time.parse(options.fetch(:time_started_at, Time.now.to_s))
        time_paused_at = 0
        time_restarted_at = time_started_at
        partial_time_spent = 0

        puts "Logging time for #{issue_key}..."
        puts time_started_at
        puts
        puts "Press CTRL-P to pause/restart the timer"
        puts "Press CTRL-C when you have finished to track the time"

        reader = TTY::Reader.new
        reader.on(:keyctrl_p) do
          if time_paused_at == 0
            time_paused_at = Time.now
            partial_time_spent = partial_time_spent + (time_paused_at - time_restarted_at)

            time_unit =
                if (partial_time_spent / 60).floor == 1
                  "minute"
                else
                  "minutes"
                end

            puts
            puts "Timer has been paused with #{(partial_time_spent / 60).floor} #{time_unit} logged"
          else
            time_paused_at = 0
            time_restarted_at = Time.now
            puts
            puts "Timer has been restarted"
          end
        end

        loop do
          reader.read_line("")
        rescue Interrupt
          total_time_spent = (partial_time_spent + (Time.now - time_restarted_at)).floor

          # Jira work logs have minute sensitivity thus API calls will fail with a time spent
          # which is less than 60 seconds

          fail! "Jira can't log less than 60 seconds of work" if total_time_spent < 60

          worklog_file = Jirawatch.configuration.template_worklog_file % time_started_at.to_i
          worklog_lines = []

          File.write worklog_file, options.fetch(:worklog_message) if options.key? :worklog_message
          TTY::Editor.open(
              worklog_file,
              content: "\n" +
                  "# You spent #{(total_time_spent / 60).floor} minutes on this issue\n" +
                  "# Write here your work log description\n" +
                  "# If you leave this empty, no work log will be saved"
          ) unless options.key? :worklog_message

          File.readlines(Jirawatch.configuration.template_worklog_file % time_started_at.to_i).each do |line|
            worklog_lines << line unless line.start_with?("#") or line.strip.empty?
          end

          @jira_client.Issue.find(issue_key).worklogs.build.save(
              {
                  timeSpentSeconds: total_time_spent,
                  started: time_started_at.strftime("%Y-%m-%dT%H:%M:%S.%L%z"),
                  comment: worklog_lines.join("\n")
              }
          ) unless worklog_lines.empty?

          puts "Worklog was empty, time was not tracked" if worklog_lines.empty?

          File.delete worklog_file
          exit
        end
      end
    end
  end
end
