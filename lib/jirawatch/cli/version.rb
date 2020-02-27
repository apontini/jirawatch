require "dry/cli"
require 'jirawatch/info'

module Jirawatch
  module CLI
    class Version < Dry::CLI::Command
      def call(*)
        puts Jirawatch::Info::VERSION
      end
    end
  end
end
