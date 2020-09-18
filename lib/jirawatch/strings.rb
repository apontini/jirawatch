module Jirawatch
  class Strings

    attr_reader :tracking_file_content
    attr_reader :tracking_cli
    attr_reader :tracking_paused
    attr_reader :tracking_restarted
    attr_reader :tracking_less_than_60_secs
    attr_reader :error_empty_worklog
    attr_reader :error_invalid_tracking_start
    attr_reader :error_login_info_not_found

    def initialize
      @tracking_file_content = [
          "",
          "# You spent %d minutes on this issue",
          "# Write here your work log description",
          "# If you leave this empty, no work log will be saved"
      ].join "\n"

      @tracking_cli = [
          "Logging time for %s: %s",
          "Started at: %s",
          "Press CTRL-P to pause/restart tracking time",
          "Press CTRL-C to stop tracking time"
      ].join "\n"

      @tracking_paused = [
          "",
          "Tracking has been paused with %d %s logged"
      ].join "\n"

      @tracking_restarted = [
          "",
          "Tracking has been restarted",
      ].join "\n"

      @tracking_less_than_60_secs =
          "Jira can't log less than 60 seconds of work"

      @error_empty_worklog =
          "Worklog was empty, time was not tracked"

      @error_invalid_tracking_start =
          "Could not start tracking in a future time"

      @error_login_info_not_found = [
          "Login info not found, please use:",
          "",
          "jirawatch login",
          ""
      ].join "\n"
    end

  end
end
