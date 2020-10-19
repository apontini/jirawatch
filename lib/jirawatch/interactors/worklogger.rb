module Jirawatch
  module Interactors
    class Worklogger
      def initialize (editor: TTY::Editor)
        @editor = editor
      end

      def call(jira_client, issue_key, total_time_spent, tracking_started_at, default_message: "")
        # Jira work logs have minute sensitivity thus API calls will fail with a time spent
        # which is less than 60 seconds
        fail! Jirawatch.strings.tracking_less_than_60_secs if total_time_spent < 60

        worklog_file = Jirawatch.configuration.template_worklog_file % tracking_started_at.to_i
        worklog_lines = []

        File.write worklog_file, default_message
        @editor.open(
            worklog_file,
            content: Jirawatch.strings.tracking_file_content % (total_time_spent / 60)
        ) if default_message.empty?

        File.readlines(Jirawatch.configuration.template_worklog_file % tracking_started_at.to_i).each do |line|
          worklog_lines << line unless line.start_with?("#") or line.strip.empty?
        end

        jira_client.Issue.find(issue_key).worklogs.build.save(
            {
                timeSpentSeconds: total_time_spent,
                started: tracking_started_at.strftime("%Y-%m-%dT%H:%M:%S.%L%z"),
                comment: worklog_lines.join("\n")
            }
        ) unless worklog_lines.empty?

        puts Jirawatch.strings.error_empty_worklog if worklog_lines.empty?

        File.delete worklog_file
      end
    end
  end
end
