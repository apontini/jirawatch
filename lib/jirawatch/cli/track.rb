module Jirawatch
  module CLI
    class Track < Dry::CLI::Command
      def call(*)
        puts 'tracking here'
      end
    end
  end
end
