require 'dry/cli'
require 'jirawatch/cli/version'
require 'jirawatch/cli/track'

module Jirawatch
  extend Dry::CLI::Registry
end

Jirawatch.register "version", Jirawatch::CLI::Version
Jirawatch.register "track", Jirawatch::CLI::Track
