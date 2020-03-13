require 'dry/cli'
require 'jirawatch/jira/provisioning'
require 'fileutils'

Dir['lib/jirawatch/cli/*'].sort.each do |file|
  require File.expand_path(file)
end

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
Jirawatch.register "projects", Jirawatch::CLI::Projects
Jirawatch.register "issues", Jirawatch::CLI::Issues
