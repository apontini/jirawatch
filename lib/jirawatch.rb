require "dry/cli"

module Jirawatch
  extend Dry::CLI::Registry
end

Jirawatch.register "hello", Jirawatch::CLI::Version
