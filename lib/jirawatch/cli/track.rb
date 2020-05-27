require 'tty-editor'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :issue_key, required: true, desc: "Issue key that you want to track time for"
      option :started_at, aliases: ["-t"], desc: "Specify when you started working on this issue with a HH:mm format"
      option :worklog_message, aliases: ["-m"], desc: "Specify a work log message"

      def call(issue_key:, **options)
        @jira_client.Issue.find(issue_key) # Fails if issue doesn't exist

        started_at = Time.parse(options.fetch(:started_at, Time.now.to_s))
        # Time when the timer is paused
        paused_at = 0
        # Time when the timer is restarted
        restarted_at = started_at
        # Represents all the seconds of actual work spent (it does not count the time of the pauses)
        partial_time_spent = 0

        puts "Logging time for #{issue_key}..."
        puts started_at
        puts "\n"
        puts "Press space to pause/restart the timer"
        puts "Press enter (or CTRL-X) when you have finished to track the time"

        reader = TTY::Reader.new
        reader.on(:keyspace) do
          if paused_at == 0
            paused_at = Time.now
            partial_time_spent = (partial_time_spent + (paused_at - restarted_at)).floor

            # Unit of time printed (the default is always plural)
            time_unit = "minutes"
            if (partial_time_spent / 60) == 1
              time_unit = "minute"
            end

            puts "\n\n"
            puts "===  PAUSE  ==="
            puts "Time spent until now: #{(partial_time_spent / 60)} #{time_unit}"
            puts "I hope you will come back soon :("
          else
            paused_at = 0
            restarted_at = Time.now
            puts "\n\n"
            puts "===  RESTART  ==="
            puts "Now is the time to work hard!"
          end
        end

        reader.on(:keyenter, :keyctrl_x) do
          total_time_spent = (partial_time_spent + (Time.now - restarted_at)).floor

          # Jira work logs have minute sensitivity thus API calls will fail with a time spent
          # which is less than 60 seconds

          fail! "Jira can't log less than 60 seconds of work" if total_time_spent < 60

          worklog_file = Jirawatch.configuration.template_worklog_file % started_at.to_i
          worklog_lines = []

          File.write worklog_file, options.fetch(:worklog_message) if options.key? :worklog_message
          TTY::Editor.open(
              worklog_file,
              content: "\n" +
                  "# You spent #{(total_time_spent / 60).floor} minutes on this issue\n" +
                  "# Write here your work log description\n" +
                  "# If you leave this empty, no work log will be saved"
          ) unless options.key? :worklog_message

          File.readlines(Jirawatch.configuration.template_worklog_file % started_at.to_i).each do |line|
            worklog_lines << line unless line.start_with?("#") or line.strip.empty?
          end

          @jira_client.Issue.find(issue_key).worklogs.build.save(
              {
                  timeSpentSeconds: total_time_spent,
                  started: started_at.strftime("%Y-%m-%dT%H:%M:%S.%L%z"),
                  comment: worklog_lines.join("\n")
              }
          ) unless worklog_lines.empty?

          puts "Worklog was empty, time was not tracked" if worklog_lines.empty?

          File.delete worklog_file
          exit
        end

        loop do
          reader.read_line("")
        rescue Interrupt
          # This is executed when the user presses CTRL-C, the only thing to do is to quit the program
          exit
        end
      end
    end
  end
end
