require 'jirawatch/jira/provisioning'

module Jirawatch
  module CLI
    class Login < Dry::CLI::Command
      include Jirawatch::Jira::Provisioning

      def call(*)
        puts "Enter you Jira URL (eg. https//veryimportantcompany.atalassian.net"
        site = STDIN.gets.chomp
        puts "Please enter your jira email/username: "
        name = STDIN.gets.chomp
        puts "Please enter your API auth token: "
        token = STDIN.gets.chomp
        save_credentials name, token, site
      end
    end
  end
end

