require 'jirawatch/jira/provisioning'

module Jirawatch
  module CLI
    class Login < Dry::CLI::Command
      include Jirawatch::Jira::Provisioning

      def call(*)
        puts "Enter your Jira URL (eg. https://veryimportantcompany.atlassian.net)"
        site = STDIN.gets.chomp
        puts "Enter your jira email/username: "
        name = STDIN.gets.chomp
        puts "Enter your API auth token: "
        token = STDIN.gets.chomp

        unless login name, token, site
          puts "Login failed, no credentials have been saved"
          return
        end

        save_credentials name, token, site
        puts "Login successful, credentials have been saved"
      end
    end
  end
end

