require 'tty-editor'

module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      include Jirawatch::CLI::AuthenticatedCommand

      argument :issue_key, required: true, desc: "Issue key that you want to track time for"
      option :tracking_started_at, aliases: ["-t"], desc: "Specify when you started working on this issue with a HH:mm format"
      option :worklog_message, aliases: ["-m"], desc: "Specify a work log message"

      def initialize(
          reader: TTY::Reader.new,
          worklogger: Jirawatch::Interactors::Worklogger.new
      )
        @reader = reader
        @worklogger = worklogger
      end

      def call(issue_key:, **options)
        tracking_started_at = Time.parse(options.fetch(:tracking_started_at, Time.now.to_s))
        fail! Jirawatch.strings.error_invalid_tracking_start if tracking_started_at > Time.now

        issue = @jira_client.Issue.find(issue_key) # Fails if issue doesn't exist

        paused = false
        tracking_restarted_at = tracking_started_at.to_i
        partial_time_spent = 0

        worked_hours = ((issue.attrs["fields"]["timetracking"]["timeSpentSeconds"].presence || 0)/60)/60
        worked_minutes = ((issue.attrs["fields"]["timetracking"]["timeSpentSeconds"].presence || 0)/60)%60
        estimate_hours = ((issue.attrs["fields"]["timetracking"]["originalEstimateSeconds"].presence || 0)/60)/60
        estimate_minutes = ((issue.attrs["fields"]["timetracking"]["originalEstimateSeconds"].presence || 0)/60)%60
        puts Jirawatch.strings.tracking_cli_name % [issue_key, issue.attrs["fields"]["summary"]]
        puts Jirawatch.strings.tracking_cli_time % [tracking_started_at.strftime("%Y-%m-%d %H:%M:%S"), worked_hours, worked_minutes, estimate_hours, estimate_minutes]
        puts Jirawatch.strings.tracking_cli_inputs

        @reader.on(:keyctrl_p) do
          unless paused
            partial_time_spent += Time.now.to_i - tracking_restarted_at
            time_unit = partial_time_spent / 60 == 1 ? "minute" : "minutes"
            puts Jirawatch.strings.tracking_paused % [partial_time_spent / 60, time_unit]
          else
            tracking_restarted_at = Time.now.to_i
            puts Jirawatch.strings.tracking_restarted
          end
          paused = !paused
        end

        begin
          loop do
            @reader.read_line("")
          end
        rescue Interrupt
          total_time_spent = partial_time_spent + (Time.now.to_i - tracking_restarted_at) unless paused
          total_time_spent = partial_time_spent if paused
          @worklogger.call @jira_client, issue_key, total_time_spent, tracking_started_at, default_message: options.fetch(:worklog_message, "")
        end
      end
    end
  end
end
