module Jirawatch
  class Config

    attr_accessor :template_track_file

    attr_accessor :config_path

    attr_accessor :login_file

    def initialize
      @template_track_file = "/tmp/jirawatch-%s"
      @config_path = File.expand_path "~/.jirawatch"
      @login_file = File.expand_path "~/.jirawatch/access"
    end
  end
end
