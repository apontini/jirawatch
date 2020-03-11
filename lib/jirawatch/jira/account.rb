module Jirawatch
  module Jira
    class Account
      attr_reader :username

      def initialize(username)
        @username = username
      end
    end
  end
end
