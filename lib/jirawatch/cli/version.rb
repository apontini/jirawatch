require "dry/cli"

module Jirawatch
  module CLI
    class Version < Dry::CLI::Command
      def call(*)
        puts "Hello"
      end
    end
  end
end
