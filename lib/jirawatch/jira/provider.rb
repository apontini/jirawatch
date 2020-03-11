require 'jirawatch/jira/account'

module Jirawatch
  module Jira
    module Provider
      def self.login
        puts 'Logging in...'
        Account.new("random")
      end
    end
  end
end
