require 'dry/cli'
require 'jirawatch/cli/version'
require 'jirawatch/cli/track'
require 'jirawatch/cli/login'
require 'jirawatch/jira/provisioning'
require 'fileutils'

module Jirawatch
  extend Dry::CLI::Registry
  include Jirawatch::Jira::Provisioning

  unless Dir.exist? @@config_path
    puts "Creating jirawatch config directory at #{@@config_path}"
    FileUtils.mkdir_p @@config_path
  end
end

Jirawatch.register "version", Jirawatch::CLI::Version
Jirawatch.register "track", Jirawatch::CLI::Track
Jirawatch.register "login", Jirawatch::CLI::Login
