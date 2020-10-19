require 'fileutils'

module Jirawatch
  extend Dry::CLI::Registry
  include Jirawatch::Jira::Provisioning

  attr_accessor :configuration
  attr_accessor :strings

  class << self
    def configuration
      @configuration || Jirawatch::Config.new
    end

    def configure
      @configuration ||= Jirawatch::Config.new
      yield @configuration
    end

    def strings
      @strings || Jirawatch::Strings.new
    end
  end

  unless Dir.exist? configuration.config_path
    puts "Creating jirawatch config directory at #{configuration.config_path}"
    FileUtils.mkdir_p configuration.config_path
  end
end

Jirawatch.register "version", Jirawatch::CLI::Version
Jirawatch.register "track", Jirawatch::CLI::Track
Jirawatch.register "login", Jirawatch::CLI::Login
Jirawatch.register "projects", Jirawatch::CLI::Projects
Jirawatch.register "issues", Jirawatch::CLI::Issues
